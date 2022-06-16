class Submission < ApplicationRecord
  acts_as_taggable_on :tags
  include AASM

  belongs_to :form, counter_cache: :response_count
  attr_accessor :fba_directive # for SPAM capture

  validate :validate_custom_form
  validates :uuid, uniqueness: true

  before_create :set_uuid
  after_commit :send_notifications, on: :create

  after_create :update_form

  scope :archived, -> { where(archived: true) }
  scope :non_archived, -> { where(archived: false) }
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
      transitions from: [:dispatched, :archived], to: :responded
    end
    event :archive do
      transitions to: :archived
    end
    event :reset do
      transitions to: :received
    end
  end

  def validate_custom_form
    @valid_form_condition = false

    questions = self.form.questions

    # Isolate questions that were answered
    answered_questions = self.attributes.select { |key, value| value.present? }
    # Filter out all non-question attributes
    answered_questions.delete("touchpoint_id")
    answered_questions.delete("form_id")
    answered_questions.delete("user_agent")
    answered_questions.delete("page")
    answered_questions.delete("ip_address")
    answered_questions.delete("language")
    answered_questions.delete("referer")

    # For each question
    # Run Custom Validations
    questions.each do |question|
      if question.is_required && !answered_questions[question.answer_field]
        errors.add(question.answer_field.to_sym, :blank, message: "is required")
      end

      if question.character_limit.present? && answered_questions[question.answer_field] && answered_questions[question.answer_field].length > question.character_limit
        errors.add(question.answer_field.to_sym, :blank, message: "exceeds character limit of #{question.character_limit}")
      end
    end
  end

  def send_notifications
    Event.log_event(Event.names[:touchpoint_form_submitted], 'Submission', self.id, "Submission received for organization '#{self.organization_name}' form '#{self.form.name}' ")
    return unless ENV["ENABLE_EMAIL_NOTIFICATIONS"] == "true"
    return unless self.form.send_notifications?

    emails_to_notify = self.form.notification_emails.split(',')
    if form.notification_frequency == "instant"
      UserMailer.submission_notification(submission_id: self.id, emails: emails_to_notify.uniq).deliver_later
    end
  end

  def self.send_daily_notifications
    form_ids = Submission.where("created_at > ?", 1.day.ago).pluck(:form_id).uniq
    form_ids.each do |form_id|
      UserMailer.submissions_digest(form_id, 1.day.ago).deliver_later
    end
  end

  def self.send_weekly_notifications
    form_ids = Submission.where("created_at > ?", 7.days.ago).pluck(:form_id).uniq
    form_ids.each do |form_id|
      UserMailer.submissions_digest(form_id, 7.days.ago).deliver_later
    end
  end

  def update_form
    form.update(last_response_created_at: created_at)
  end

  def to_rows
    values = self.form.questions.collect(&:answer_field)

    values = values + [
      self.ip_address,
      self.user_agent,
      self.page,
      self.referer,
      self.created_at
    ]

    values
  end

  def organization_name
    form.organization.present? ? form.organization.name : "Org Name"
  end

  def set_uuid
    self.uuid = SecureRandom.uuid if !self.uuid.present?
  end
end
