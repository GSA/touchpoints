class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.submission_notification.subject
  #
  def submission_notification(submission_id:, emails: [])
    set_logo
    @submission = Submission.find(submission_id)
    @form = @submission.form
    admin_emails = ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(",")
    mail subject: "New Submission to #{@form.name}",
      to: emails
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.admin_summary.subject
  #
  def admin_summary
    set_logo
    @greeting = "Hi, admin_summary"

    mail to: ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(",")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.webmaster_summary.subject
  #
  def webmaster_summary
    set_logo
    @greeting = "Hi, webmaster_summary"

    mail to: ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(",")
  end

  def new_user_notification(user)
    set_logo
    @user = user
    mail subject: "New user account created",
      to: UserMailer.touchpoints_team
  end

  def form_expiring_notification(form)
    set_logo
    @form = form
    mail subject: "Form #{@form.name} expiring on #{@form.expiration_date}",
      to: ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(",")
  end

  def org_user_notification(user, org_admin)
    set_logo
    @user = user
    @org_admin = org_admin
    mail subject: "New user added to organization",
      to: org_admin.email
  end

  def no_org_notification(user)
    set_logo
    @user = user
    mail subject: "New user account creation failed",
      to: UserMailer.touchpoints_support
  end

  def account_deactivated_notification(user)
    set_logo
    @user = user
    mail subject: "User account deactivated",
      to: UserMailer.touchpoints_team
  end

  def invite(user, invitee)
    set_logo
    Event.log_event(Event.names[:user_send_invitation], "User", user.id, "User #{user.email} invited #{invitee} at #{Time.now.to_s}")
    attachments.inline["logo.png"] = @@header_logo
    @user = user
    @invitee = invitee
    mail subject: "Touchpoints invite", to: @invitee
  end

  private

  def self.touchpoints_team
    ENV.fetch('TOUCHPOINTS_TEAM') { 'feedback-analytics@gsa.gov' }
  end

  def self.touchpoints_support
    ENV.fetch('TOUCHPOINTS_SUPPORT') { 'feedback-analytics@gsa.gov' }
  end
end
