class Submission < ApplicationRecord
  belongs_to :form

  validate :validate_custom_form

  after_create :send_notifications

  scope :non_flagged, -> { where(flagged: false) }

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
        errors.messages[question.answer_field] << "is required"
      end

      if question.character_limit.present? && answered_questions[question.answer_field] && answered_questions[question.answer_field].length > question.character_limit
        errors.messages[question.answer_field] << "exceeds character limit of #{question.character_limit}"
      end
    end
  end

  def send_notifications
    Event.log_event(Event.names[:touchpoint_form_submitted], 'Submission', self.id, "Submission received for organization '#{self.organization_name}' form '#{self.form.name}' ")
    return unless ENV["ENABLE_EMAIL_NOTIFICATIONS"] == "true"
    return unless self.form.send_notifications?
    return unless self.form.notification_emails?
    emails_to_notify = self.form.notification_emails.split(",")

    # Add Form Manager(s) to notification distribution list
    self.form.users.select { | u | self.form.user_role?(user: u) == UserRole::Role::FormManager }.each do |mgr|
      emails_to_notify << mgr.email
    end

    UserMailer.submission_notification(submission: self, emails: emails_to_notify.uniq).deliver_later
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
end
