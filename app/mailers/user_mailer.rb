class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.submission_notification.subject
  #
  def submission_notification(submission:, emails: [])
    attachments.inline["logo.png"] = @@header_logo
    @submission = submission
    @touchpoint = @submission.touchpoint
    mail subject: "New Submission to #{@touchpoint.name}",
      to: emails,
      bcc: ["ryan.wold@gsa.gov", "lauren.ancona@gsa.gov"]
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.admin_summary.subject
  #
  def admin_summary
    @greeting = "Hi, admin_summary"

    mail to: "ryan.wold@gsa.gov"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.webmaster_summary.subject
  #
  def webmaster_summary
    @greeting = "Hi, webmaster_summary"

    mail to: "ryan.wold@gsa.gov"
  end

  def new_user_notification(user)
    attachments.inline["logo.png"] = @@header_logo
    @user = user
    mail subject: "New user account created",
      to: UserMailer.touchpoints_team

  end

  def org_user_notification(user, org_admin)
    attachments.inline["logo.png"] = @@header_logo
    @user = user
    @org_admin = org_admin
    mail subject: "New user added to organization",
      to: org_admin.email
  end

  def no_org_notification(user)
    attachments.inline["logo.png"] = @@header_logo
    @user = user
    mail subject: "New user account creation failed",
      to: UserMailer.touchpoints_support

  end

private

  def self.touchpoints_team
    ENV.fetch('TOUCHPOINTS_TEAM') { 'feedback-analytics@gsa.gov' }
  end

  def self.touchpoints_support
    ENV.fetch('TOUCHPOINTS_SUPPORT') { 'feedback-analytics@gsa.gov' }
  end
end
