# frozen_string_literal: true

class UserMailer < ApplicationMailer
  ASYNC_JOB_MESSAGE = "Touchpoints has initiated an asynchronous job that will take a few minutes. <br>Please check your email for a link to the report."

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.submission_notification.subject
  #
  def notification(title: '', body: '', path: '', emails: [])
    set_logo

    @body = body
    @path = path

    mail subject: "Touchpoints notification: #{title}",
         to: emails
  end

  def async_report_notification(email:, start_time:, completion_time:, record_count:, url:)
    set_logo
    @start_time = start_time
    @completion_time = completion_time
    @record_count = record_count
    @url = url
    mail subject: "Touchpoints export is now available",
         to: email,
         bcc: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')).uniq
  end

  def form_feedback(form_id:, email:)
    set_logo
    @form = Form.find(form_id)
    @feedback_url = "https://touchpoints.app.cloud.gov/touchpoints/522e395c/submit?location_code=#{@form.short_uuid}"
    mail subject: "How was your Touchpoints experience with form #{@form.name}?",
         to: ([email] + ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')).uniq
  end

  def submission_notification(submission_id:, emails: [])
    set_logo
    @submission = Submission.find(submission_id)
    @form = @submission.form
    mail subject: "New Submission to #{@form.name}",
         to: emails
  end

  def form_status_changed(form:, action:, event:)
    set_logo
    @form = form
    @action = action
    @event = event
    mail subject: "Touchpoints form #{@form.name} #{@action}",
         to: ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
  end

  def user_welcome_email(email:)
    set_logo
    @email = email
    mail subject: "Welcome to Touchpoints",
      to: email,
      bcc: ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
  end

  def service_event_notification(subject:, service:, event:, link: '')
    set_logo
    @subject = subject
    @service = service
    @event = event
    @link = link
    mail subject: "Touchpoints event notification: #{subject}",
         to: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.service_managers.collect(&:email)).uniq
  end

  def collection_notification(collection_id:)
    set_logo
    @collection = Collection.find(collection_id)
    mail subject: "Data Collection notification to #{@collection.name}",
         to: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.performance_managers.collect(&:email)).uniq
  end

  def cx_collection_notification(cx_collection_id:)
    set_logo
    @cx_collection = CxCollection.find(cx_collection_id)
    mail subject: "CX Data Collection notification to #{@cx_collection.name}",
         to: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.performance_managers.collect(&:email)).uniq
  end

  def cscrm_data_collection_notification(collection_id:)
    set_logo
    @collection = CscrmDataCollection.find(collection_id)
    mail subject: "CSCRM Data Collection notification to #{@collection.id}",
      to: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.where(cscrm_data_collection_manager: true).collect(&:email)).uniq
  end

  def cscrm_data_collection2_notification(collection_id:)
    set_logo
    @collection = CscrmDataCollection2.find(collection_id)
    mail subject: "CSCRM Data Collection 2 notification to #{@collection.id}",
      to: (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.where(cscrm_data_collection_manager: true).collect(&:email)).uniq
  end

  def quarterly_performance_notification(collection_id:)
    set_logo
    @collection = Collection.find(collection_id)
    mail subject: "Quarterly Performance Data Collection Ready: #{@collection.name}",
         to: @collection.user.email, cc: User.performance_managers.collect(&:email).uniq
  end

  def submissions_digest(form_id, begin_day)
    return unless ENV['ENABLE_EMAIL_NOTIFICATIONS'] == 'true'

    @begin_day = begin_day
    @form = Form.find(form_id)
    return unless @form.send_notifications?

    set_logo
    @submissions = Submission.where(id: form_id).where('created_at > ?', @begin_day).order('created_at desc')
    emails = @form.notification_emails.split(',')
    mail subject: "New Submissions to #{@form.name} since #{@begin_day}", to: emails
  end

  def account_deactivation_scheduled_notification(email, active_days)
    return unless ENV['ENABLE_EMAIL_NOTIFICATIONS'] == 'true'

    @active_days = active_days
    set_logo

    mail subject: "Your account is scheduled to be deactivated in #{@active_days} days due to inactivity", to: email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.admin_summary.subject
  #
  def admin_summary
    set_logo
    @greeting = 'Hi, admin_summary'

    mail to: ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.webmaster_summary.subject
  #
  def webmaster_summary
    set_logo
    @greeting = 'Hi, webmaster_summary'

    mail to: ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
  end

  def website_created(website:, created_by_user:)
    return unless website

    set_logo
    @website = website
    @user = created_by_user
    if @website.organization.abbreviation == "GSA"
      @emails = (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',') + User.organizational_website_managers.collect(&:email)).uniq
    else
      @emails = (ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')).uniq
    end
    mail subject: 'Touchpoints notification: Website created', to: @emails
  end

  def website_data_collection(email, websites)
    return unless email

    set_logo
    @greeting = "Hi, #{email}"
    @email = email
    @websites = websites
    mail subject: 'Website Data Collection Request', to: email
  end

  def website_backlog_data_collection(email, websites)
    return unless email

    set_logo
    @greeting = "Hi, #{email}"
    @email = email
    @websites = websites
    mail subject: 'Update Website record', to: email
  end

  def new_user_notification(user)
    set_logo
    @user = user
    mail subject: 'New user account created',
         to: UserMailer.touchpoints_team
  end

  def form_expiring_notification(form)
    set_logo
    @form = form
    mail subject: "Form #{@form.name} expiring on #{@form.expiration_date}",
         to: ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
  end

  def org_user_notification(user, org_admin)
    set_logo
    @user = user
    @org_admin = org_admin
    mail subject: 'New user added to organization',
         to: org_admin.email
  end

  def no_org_notification(user)
    set_logo
    @user = user
    mail subject: 'New user account creation failed',
         to: UserMailer.touchpoints_support
  end

  def account_deactivated_notification(user)
    set_logo
    @user = user
    mail subject: 'User account deactivated',
         to: UserMailer.touchpoints_team
  end

  def invite(user, invitee)
    set_logo
    Event.log_event(Event.names[:user_send_invitation], 'User', user.id, "User #{user.email} invited #{invitee} at #{Time.zone.now}")
    attachments.inline['logo.png'] = @@header_logo
    @user = user
    @invitee = invitee
    mail subject: 'Touchpoints invite', to: @invitee
  end

  def self.registry_manager_emails
    User.registry_managers.collect(&:email).join(',')
  end

  def self.touchpoints_team
    ENV.fetch('TOUCHPOINTS_TEAM', 'feedback-analytics@gsa.gov')
  end

  def self.touchpoints_support
    ENV.fetch('TOUCHPOINTS_SUPPORT', 'feedback-analytics@gsa.gov')
  end
end
