# frozen_string_literal: true

class Submission < ApplicationRecord
  include AASM

  belongs_to :form, counter_cache: :response_count
  attr_accessor :fba_directive # for SPAM capture

  validate :validate_custom_form
  validates :uuid, uniqueness: true

  before_create :set_uuid
  after_create :update_form
  after_create :set_preview
  after_commit :send_notifications, on: :create

  scope :active, -> { where(flagged: false, spam: false, archived: false, deleted: false) }
  scope :reportable, -> { where(flagged: false, spam: false, deleted: false) }
  scope :ordered, -> { order("created_at DESC") }
  scope :archived, -> { where(archived: true) }
  scope :non_archived, -> { where(archived: false) }
  scope :flagged, -> { where(flagged: true) }
  scope :non_flagged, -> { where(flagged: false) }
  scope :marked_as_spam, -> { where(spam: true) }
  scope :not_marked_as_spam, -> { where(spam: false) }
  scope :deleted, -> { where(deleted: true) }
  scope :non_deleted, -> { where(deleted: false) }

  aasm do
    state :received, initial: true
    state :acknowledged
    state :dispatched
    state :responded

    event :acknowledge do
      transitions from: [:received], to: :acknowledged
    end
    event :dispatch do
      transitions from: [:acknowledged], to: :dispatched
    end
    event :respond do
      transitions from: %i[dispatched], to: :responded
    end
    event :reset do
      transitions to: :received
    end
  end

  # Validate each submitted field against its question type
  def validate_custom_form
    # Isolate questions that were answered
    answered_questions = attributes.select { |_key, value| value.present? }

    # Filter out all non-question attributes
    answered_questions.delete('id')
    answered_questions.delete('uuid')
    answered_questions.delete('touchpoint_id')
    answered_questions.delete('form_id')
    answered_questions.delete('user_agent')
    answered_questions.delete('hostname')
    answered_questions.delete('page')
    answered_questions.delete('query_string')
    answered_questions.delete('ip_address')
    answered_questions.delete('language')
    answered_questions.delete('referer')
    answered_questions.delete('aasm_state')
    answered_questions.delete('tags')
    answered_questions.delete('spam_prevention_mechanism')
    answered_questions.delete('spam_score')
    answered_questions.delete('flagged')
    answered_questions.delete('spam')
    answered_questions.delete('archived')
    answered_questions.delete('deleted')
    answered_questions.delete('preview')
    answered_questions.delete('created_at')
    answered_questions.delete('updated_at')
    answered_questions.delete('deleted_at')

    # Ensure only requested fields are submitted
    expected_submission_fields = form.questions.collect(&:answer_field) + ["location_code"]
    actual_submission_fields = answered_questions.keys
    unexpected_fields = actual_submission_fields - expected_submission_fields
    errors.add(:base, :invalid, message: "received invalid submission field(s): #{unexpected_fields.to_sentence}") if unexpected_fields.present?

    # Assess each provided answer field against question-specific validations
    form.questions.each do |question|
      provided_answer = answered_questions[question.answer_field]

      if provided_answer.nil? && question.is_required
        errors.add(question.answer_field.to_sym, :blank, message: 'is required')
      end

      unless form.enforce_new_submission_validations || ENV.fetch("ENFORCE_NEW_SUBMISSION_VALIDATIONS", false)
        next
      end

      next unless provided_answer.present?

      # General validation logic for all Question types
      if question.character_limit.present? && provided_answer.length > question.character_limit
        errors.add(question.answer_field.to_sym, :invalid, message: "exceeds character limit of #{question.character_limit}")
      end

      # Custom validation logic per specific Question type
      case question.question_type
      when "text_field"
      when "text_email_field"
        unless provided_answer =~ /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
          errors.add(question.answer_field.to_sym, :invalid, message: "must be a valid email address")
        end
      when "text_phone_field"
        unless provided_answer =~ /\A\d{10}\z/
          errors.add(question.answer_field.to_sym, :invalid, message: "must be a 10 digit phone number")
        end
      when "textarea"
      when "checkbox"
        valid_multiple_choice_options = question.question_options.collect(&:value)
        input_values = provided_answer.split(",")

        invalid_values = input_values - valid_multiple_choice_options
        accepts_other_response = question.has_other_question_option?

        if accepts_other_response && invalid_values.size > 1 #
          errors.add(:question, "#{question.answer_field} contains more than 1 'other' value: #{invalid_values.join(', ')}")
        elsif !accepts_other_response && invalid_values.any?
          errors.add(:question, "#{question.answer_field} contains invalid values: #{invalid_values.join(', ')}")
        end
      when "radio_buttons", "dropdown", "combobox"
        valid_multiple_choice_options = question.question_options.where(other_option: false).collect(&:value)
        accepts_other_response = question.has_other_question_option?

        if valid_multiple_choice_options.include?(provided_answer)
          # okay
        elsif accepts_other_response
          # okay to accept one `other` answer
        else
          errors.add(:question, "#{question.answer_field} contains invalid values")
        end
      when "text_display", "custom_text_display"
        errors.add(:text_display, "#{question.answer_field} should not contain a value")
      when "states_dropdown"
        unless UsState.dropdown_options.map { |option| option[1] }.include?(provided_answer)
          errors.add(:question, "#{question.answer_field} does not contain a valid State option")
        end
      when "star_radio_buttons"
        valid_multiple_choice_options = ["1", "2", "3", "4", "5"]
        # only accept 1-5
        if !valid_multiple_choice_options.include?(provided_answer)
          errors.add(:star_radio_buttons, "#{question.answer_field} contains an non 1-5 response")
        end
      when "big_thumbs_up_down_buttons", "yes_no_buttons"
        valid_multiple_choice_options = ["0", "1"]

        # only accept 0 or 1; no/yes
        unless valid_multiple_choice_options.include?(provided_answer)
          errors.add(:yes_no_buttons, "#{question.answer_field} contains an non yes/no response")
        end
      when "hidden_field"
      when "date_select"
        begin
          Date.strptime(provided_answer, "%m/%d/%Y")
        rescue ArgumentError
          errors.add(question.answer_field.to_sym, :invalid, message: "must be a MM/DD/YYYY date")
        end
      end

    end
  end

  def send_notifications
    Event.log_event(Event.names[:touchpoint_form_submitted], 'Submission', id, "Submission received for organization '#{organization_name}' form '#{form.name}' ")
    return unless ENV['ENABLE_EMAIL_NOTIFICATIONS'] == 'true'
    return unless form.send_notifications?

    emails_to_notify = form.notification_emails.split(',')
    UserMailer.submission_notification(submission_id: id, emails: emails_to_notify.uniq).deliver_later if form.notification_frequency == 'instant'
  end

  def self.send_daily_notifications
    form_ids = Submission.where('created_at > ?', 1.day.ago).pluck(:form_id).uniq
    form_ids.each do |form_id|
      UserMailer.submissions_digest(form_id, 1).deliver_later
    end
  end

  def self.send_weekly_notifications
    form_ids = Submission.where('created_at > ?', 7.days.ago).pluck(:form_id).uniq
    form_ids.each do |form_id|
      UserMailer.submissions_digest(form_id, 7).deliver_later
    end
  end

  def update_form
    form.update(last_response_created_at: created_at)
  end

  def to_rows
    values = form.ordered_questions.collect(&:answer_field)

    values + [
      ip_address,
      user_agent,
      page,
      referer,
      created_at,
    ]
  end

  def organization_name
    form.organization.present? ? form.organization.name : 'Org Name'
  end

  def set_preview
    # only select the answer fields
    fields = attributes.select { |attr| attr.include?("answer")}
    # only select text fields
    text_fields = fields.values.select { |v| v.is_a?(String) }
    preview_text = text_fields.join(" - ").truncate(120)
    self.update_attribute(:preview, preview_text)
  end

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def events
    @events = Event.where(object_type: 'Submission', object_uuid: self.id).order("created_at DESC")
  end
end
