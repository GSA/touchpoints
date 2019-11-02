class Submission < ApplicationRecord
  belongs_to :touchpoint

  validate :validate_custom_form, if: :form_kind_is_custom?

  scope :non_flagged, -> { where(flagged: false) }

  def validate_custom_form
    @valid_form_condition = false

    # gather all answer fields
    valid_answer_fields = self.touchpoint.form.questions.collect(&:answer_field)
    # loop the fields and ensure there is at least one answered
    valid_answer_fields.each do |valid_field|
      if self.send(valid_field).present?
        @valid_form_condition = true
      end
    end

    unless @valid_form_condition
      # push an error to a blank key to generate the generic error message
      errors[""] << "Please answer at least one of the core 7 questions."
    end
  end

  def send_notifications
    return unless self.touchpoint.send_notifications?
    return unless self.touchpoint.notification_emails?
    emails_to_notify = self.touchpoint.notification_emails
    UserMailer.submission_notification(submission: self, emails: emails_to_notify).deliver_now
  end

  # NOTE: this is brittle.
  #       this pattern will require every field to declare its validations
  #       Rethink.
  def form_kind_is_custom?
    self.touchpoint.form.kind == "custom"
  end

  def to_rows
    if self.touchpoint.form.kind == "custom"
      values = self.touchpoints.form.questions.collect(&:answer_field)
    end

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
