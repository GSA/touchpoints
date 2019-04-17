class Submission < ApplicationRecord
  belongs_to :touchpoint

  validates :first_name, presence: true, if: :form_kind_is_recruiter?
  validates :email, presence: true, if: :form_kind_is_recruiter?

  validates :body, presence: true, if: :form_kind_is_open_ended?

  validates :overall_satisfaction, presence: true, if: :form_kind_is_a11?

  after_create :send_notifications

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
        self.first_name,
        self.last_name,
        self.email
      ]
    end
    if self.touchpoint.form.kind == "open-ended"
      values = [
        self.body
      ]
    end
    if self.touchpoint.form.kind == "open-ended-with-contact-info"
      values = [
        self.body,
        self.first_name,
        self.email,
        self.referer,
        self.user_agent,
        self.url,
        self.created_at,
      ]
    end
    if self.touchpoint.form.kind == "a11"
      values = [
        self.overall_satisfaction,
        self.service_confidence,
        self.service_effectiveness,
        self.process_ease,
        self.process_efficiency,
        self.process_transparency,
        self.people_employees,
      ]
    end

    values
  end
end
