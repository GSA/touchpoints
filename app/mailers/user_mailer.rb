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

  def new_user_notification(user)
    @user = user
    mail subject: "New user account registration #{@user.email}",
      to: ENV['TOUCHPOINTS_TEAM']

  end

  def org_user_notification(user, org_admin)
    @user = user
    @org_admin = org_admin
    mail subject: "A new user has been added to your organization",
      to: org_admin.email
  end

  def no_org_notification(user)
    @user = user
    mail subject: "Problem with new user account registration, #{@user.email} -- organization not found",
      to: ENV['TOUCHPOINTS_SUPPORT']

  end
end
