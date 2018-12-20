class Submission < ApplicationRecord
  belongs_to :touchpoint

  validates :first_name, presence: true, if: :form_kind_is_recruiter?
  validates :email, presence: true, if: :form_kind_is_recruiter?

  validates :body, presence: true, if: :form_kind_is_open_ended?

  validates :overall_satisfaction, presence: true, if: :form_kind_is_a11?

  after_create :send_notifications

  def send_notifications
    return unless Rails.env.development?

    emails_to_notify = self.touchpoint.container.organization.users.collect(&:email)
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
end
