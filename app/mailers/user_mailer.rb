class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.submission_notification.subject
  #
  def submission_notification(submission:, emails: [])
    @submission = submission
    @touchpoint = @submission.touchpoint
    mail subject: "New Submission to #{@touchpoint.name}",
      to: emails,
      bcc: "ryan.wold@gsa.gov,lauren.ancona@gsa.gov"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.admin_summary.subject
  #
  def admin_summary
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.webmaster_summary.subject
  #
  def webmaster_summary
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
