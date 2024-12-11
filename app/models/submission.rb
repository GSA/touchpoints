# frozen_string_literal: true

class Submission < ApplicationRecord
  include AASM

  belongs_to :form, counter_cache: :response_count
  attr_accessor :fba_directive # for SPAM capture

  validate :validate_custom_form
  validates :uuid, uniqueness: true

  before_create :set_uuid
  after_create :update_form
  after_commit :send_notifications, on: :create

  scope :archived, -> { where(aasm_state: :archived) }
  scope :non_archived, -> { where("aasm_state != 'archived'") }
  scope :non_flagged, -> { where(flagged: false) }

  aasm do
    state :received, initial: true
    state :acknowledged
    state :dispatched
    state :responded
    state :archived

    event :acknowledge do
      transitions from: [:received], to: :acknowledged
    end
    event :dispatch do
      transitions from: [:acknowledged], to: :dispatched
    end
    event :respond do
      transitions from: %i[dispatched archived], to: :responded
    end
    event :archive do
      transitions to: :archived
    end
    event :reset do
      transitions to: :received
    end
  end

  def archived
    self.archived?
  end

  def validate_custom_form
    # Isolate questions that were answered
    answered_questions = attributes.select { |_key, value| value.present? }

    # Filter out all non-question attributes
    answered_questions.delete('touchpoint_id')
    answered_questions.delete('form_id')
    answered_questions.delete('user_agent')
    answered_questions.delete('hostname')
    answered_questions.delete('page')
    answered_questions.delete('ip_address')
    answered_questions.delete('language')
    answered_questions.delete('referer')
    answered_questions.delete('aasm_state')

    # For each question, run custom validations
    form.questions.each do |question|
      errors.add(question.answer_field.to_sym, :blank, message: 'is required') if question.is_required && !answered_questions[question.answer_field]
      errors.add(question.answer_field.to_sym, :blank, message: "exceeds character limit of #{question.character_limit}") if question.character_limit.present? && answered_questions[question.answer_field] && answered_questions[question.answer_field].length > question.character_limit

      # Custom validation logic for each type of Question
      case question.question_type
      when "text_field"
      when "text_email_field"
      when "text_phone_field"
      when "textarea"
      when "checkbox"
        valid_multiple_choice_options = question.question_options.collect(&:value)
        text_input = answered_questions[question.answer_field]
        input_values = (text_input || "").split(",")

        invalid_values = input_values - valid_multiple_choice_options
        accepts_other_response = question.has_other_question_option?
        if accepts_other_response && invalid_values.any? && invalid_values.size > 1
          errors.add(:question, "#{question.answer_field} contains more than 1 'other' value: #{invalid_values.join(', ')}")
        elsif !accepts_other_response && invalid_values.any?
          errors.add(:question, "#{question.answer_field} contains invalid values: #{invalid_values.join(', ')}")
        end
      when "radio_buttons", "dropdown", "combobox"
        valid_multiple_choice_options = question.question_options.collect(&:value)
        text_input = answered_questions[question.answer_field]
        input_values = (text_input || "").split(",")

        invalid_values = input_values - valid_multiple_choice_options
        accepts_other_response = question.has_other_question_option?

        if accepts_other_response && invalid_values.size > 1 # there may be 1 'other' response
          errors.add(:question, "#{question.answer_field} contains more than 1 'other' value: #{invalid_values.join(', ')}")
        elsif !accepts_other_response && input_values.size > 1 # there should be 1 valid response
          errors.add(:question, "#{question.answer_field} contains multiple valid values: #{invalid_values.join(', ')}")
        elsif !accepts_other_response && invalid_values.any? # there should be no invalid values
          errors.add(:question, "#{question.answer_field} contains invalid values: #{invalid_values.join(', ')}")
        end
      when "text_display", "custom_text_display"
        if answered_questions[question.answer_field]
          errors.add(:text_display, "#{question.answer_field} should not contain a value")
        end
      when "states_dropdown"
        if question.is_required
          text_input = answered_questions[question.answer_field]
          unless UsState.dropdown_options.map { |option| option[1] }.include?(text_input)
            errors.add(:question, "#{question.answer_field} does not contain a valid State option")
          end
        end
      when "star_radio_buttons"
        valid_multiple_choice_options = ["1", "2", "3", "4", "5"]
        text_input = answered_questions[question.answer_field]

        # only accept 1-5
        unless valid_multiple_choice_options.include?(answered_questions[question.answer_field])
          errors.add(:star_radio_buttons, "#{question.answer_field} contains an non 1-5 response")
        end
      when "big_thumbs_up_down_buttons", "yes_no_buttons"
        valid_multiple_choice_options = ["0", "1"]
        text_input = answered_questions[question.answer_field]

        # only accept 0 or 1; no/yes
        unless valid_multiple_choice_options.include?(answered_questions[question.answer_field])
          errors.add(:yes_no_buttons, "#{question.answer_field} contains an non yes/no response")
        end
      when "hidden_field"
      when "date_select"
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

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def events
    @events = Event.where(object_type: 'Submission', object_uuid: self.id).order("created_at DESC")
  end
end
