class Submission < ApplicationRecord
  belongs_to :touchpoint

  validate :validate_custom_form

  after_create :send_notifications

  scope :non_flagged, -> { where(flagged: false) }

  def validate_custom_form
    @valid_form_condition = false

    questions = self.touchpoint.form.questions

    # Isolate questions that were answered
    answered_questions = self.attributes.select { |key, value| value.present? }
    # Filter out all non-question attributes
    answered_questions.delete("touchpoint_id")
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
    return unless self.touchpoint.send_notifications?
    return unless self.touchpoint.notification_emails?
    emails_to_notify = self.touchpoint.notification_emails.split(",")
    #add service manager(s) to notification distribution
    self.touchpoint.service.users.select { | u | self.touchpoint.service.user_role?(user: u) == UserService::Role::ServiceManager }.each do | sm |
      emails_to_notify << sm.email unless emails_to_notify.include?(sm.email)
    end
    UserMailer.submission_notification(submission: self, emails: emails_to_notify.uniq).deliver_now
  end

  def to_rows
    values = self.touchpoints.form.questions.collect(&:answer_field)

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
    self.touchpoint.service ? self.touchpoint.service.organization.name : "Placeholder Org Name"
  end
end
