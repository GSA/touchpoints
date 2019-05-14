class Submission < ApplicationRecord
  belongs_to :touchpoint

  validate :validate_recruiter_form, if: :form_kind_is_recruiter?
  validate :validate_open_ended_form, if: :form_kind_is_open_ended?
  validate :validate_a11_form, if: :form_kind_is_a11?

  def validate_recruiter_form
    unless self.answer_01 && self.answer_01.present?
      errors.add(:first_name, "can't be blank")
    end
    unless self.answer_04 && self.answer_04.present?
      errors.add(:email, "can't be blank")
    end
  end

  def validate_open_ended_form
    unless self.answer_01 && self.answer_01.present?
      errors.add(:body, "can't be blank")
    end
    if self.answer_01 && self.answer_01.length > 2500
      errors.add(:body, "is limited to 2500 characters")
    end
  end

  def validate_a11_form
    unless self.answer_01 && self.answer_01.present?
      errors.add(:answer_01, "is required")
    end
    unless self.answer_07 && self.answer_07.present?
      errors.add(:answer_07, "is required")
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
  def form_kind_is_recruiter?
    self.touchpoint.form.kind == "recruiter"
  end

  def form_kind_is_open_ended?
    self.touchpoint.form.kind == "open-ended" ||
    self.touchpoint.form.kind == "open-ended-with-contact-info"
  end

  def form_kind_is_a11?
    self.touchpoint.form.kind == "a11"
  end

  def to_rows
    if self.touchpoint.form.kind == "recruiter"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04
      ]
    end
    if self.touchpoint.form.kind == "open-ended"
      values = [
        self.answer_01
      ]
    end
    if self.touchpoint.form.kind == "open-ended-with-contact-info"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04,
        self.answer_05,
        self.answer_06,
        self.created_at,
      ]
    end
    if self.touchpoint.form.kind == "a11"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04,
        self.answer_05,
        self.answer_06,
        self.answer_07,
        self.answer_08,
        self.answer_09,
        self.answer_10,
        self.answer_11,
        self.answer_12,
      ]
    end

    values
  end

  def organization_name
    self.touchpoint.service ? self.touchpoint.service.organization.name : "Placeholder Org Name"
  end
end
