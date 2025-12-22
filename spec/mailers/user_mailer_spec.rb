# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'submission_notification' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:inactive_user) { FactoryBot.create(:user, organization:, inactive: true) }
    let(:form) { FactoryBot.create(:form, :single_question, organization:) }
    let!(:submission) { FactoryBot.create(:submission, form:) }
    let(:mail) { UserMailer.submission_notification(submission_id: submission.id, emails: [user.email]) }

    context "with active emails" do
      it 'renders the headers' do
        expect(mail.subject).to eq("New Submission to #{submission.form.name}")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])

        expect {
          mail.deliver_now
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'renders the body' do
        expect(mail.body.encoded).to have_text('Touchpoints.gov Response Notification')
        expect(mail.body.encoded).to have_text("New feedback has been submitted to your form, #{submission.form.name}.")
      end
    end

    context "with inactive emails" do
      let(:inactive_mail) { UserMailer.submission_notification(submission_id: submission.id, emails: [inactive_user.email]) }

      it 'does not send email when recipients are inactive' do
        expect(inactive_mail.deliver_now).to eq(nil)
        expect {
          inactive_mail.deliver_now
        }.to_not change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  describe 'submission_digest' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, :single_question, organization:, notification_emails: user.email) }
    let!(:submission) { FactoryBot.create(:submission, form:) }
    let(:days_ago) { 1 }
    let(:time_threshold) { days_ago.days.ago }
    let(:mail) { UserMailer.submissions_digest(form.id, days_ago) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Touchpoints Digest: New Submissions to #{form.name} since #{time_threshold}")
      expect(mail.to).to eq(form.notification_emails.split)
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text("Notification of feedback received since #{time_threshold}")
      expect(mail.body.encoded).to have_text("1 feedback responses have been submitted to your form, #{form.name}, since #{time_threshold}")
    end
  end

  describe 'form_inactivity_email' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:inactive_form) { FactoryBot.create(:form, organization:, last_response_created_at: Time.now - 30.days) }
    let(:days_ago) { 30 }
    let(:mail) { UserMailer.form_inactivity_email(form_short_uuid: inactive_form.short_uuid, user_emails: [user.email], days_ago: days_ago) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Touchpoints form Open-ended Test form has not received a response in more than 30 days")
      expect(mail.from).to eq(["from@example.gov"])
      expect(mail.to).to eq([user.email])
      expect(mail.bcc).to eq(["admin@example.gov"])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text("The form Open-ended Test form is published in Touchpoints")
      expect(mail.body.encoded).to have_text("but has not received a response in at least 30 days.")
      expect(mail.body.encoded).to have_text("Please consider archiving the form in Touchpoints if the form is no longer in use.")
    end
  end

  describe 'form_status_changed' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, organization:) }
    let(:event) { Event.log_event(Event.names[:form_published], 'Form', form.uuid, "Form #{form.name} published at #{DateTime.now}", user.id) }
    let(:mail) { UserMailer.form_status_changed(form:, action: 'published', event: event) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Touchpoints form #{form.name} published")
      expect(mail.to).to eq(ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(','))
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('Form status changed')
      expect(mail.body.encoded).to have_text('status changed to published')
    end
  end

  describe 'quarterly_performance_update' do
    let!(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, organization:) }
    let(:service) { FactoryBot.create(:service, organization:, service_owner_id: user.id) }
    let!(:cx_collection) { FactoryBot.create(:cx_collection, user:, service:) }
    let(:mail) { UserMailer.quarterly_performance_notification(cx_collection_id: cx_collection.id) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Quarterly Performance Data Collection Ready: #{cx_collection.name}")
      expect(mail.to).to eq([cx_collection.user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('Quarterly Performance Notification')
    end
  end

  describe 'account_deactivation_scheduled_notification' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:active_days) { 14 }
    let(:mail) { UserMailer.account_deactivation_scheduled_notification(user.email, active_days) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Touchpoints account to be deactivated in #{active_days} days")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text("Your Touchpoints account is scheduled to be deactivated in #{active_days} days due to inactivity")
      expect(mail.body.encoded).to have_text("Login to Touchpoints at")
      expect(mail.body.encoded).to have_text("to keep your account active")
    end
  end

  describe 'admin_summary' do
    let(:mail) { UserMailer.admin_summary }

    it 'renders the headers' do
      expect(mail.subject).to eq('Admin summary')
      expect(mail.to).to eq(ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(','))
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('Hi')
    end
  end

  describe 'webmaster_summary' do
    let(:mail) { UserMailer.webmaster_summary }

    it 'renders the headers' do
      expect(mail.subject).to eq('Webmaster summary')
      expect(mail.to).to eq(ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(','))
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('Hi')
    end
  end

  describe 'new_user_notification' do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.new_user_notification(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New user account created')
      expect(mail.to).to eq([UserMailer.touchpoints_team])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('New user account created')
    end
  end

  describe 'notification' do
    let!(:user) { FactoryBot.create(:user, registry_manager: true) }
    let(:digital_product) { FactoryBot.create(:digital_product) }
    let(:mail) { UserMailer.notification(
      title: 'Digital Product has been created',
      body: "Digital Product #{digital_product.name} created at #{DateTime.now} by #{user.email}",
      path: admin_digital_product_url(digital_product),
      emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
    ) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Touchpoints notification: Digital Product has been created')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('Digital Product ExampleGov Mobile App created')
    end
  end

  describe 'org_user_notification' do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.org_user_notification(user, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New user added to organization')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('New user added to organization')
    end
  end

  describe 'no_org_notification' do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.no_org_notification(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New user account creation failed')
      expect(mail.to).to eq([UserMailer.touchpoints_support])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_text('New user account creation failed')
    end
  end

  describe 'form_feedback' do
    let(:user) { FactoryBot.create(:user) }
    let(:form) { FactoryBot.create(:form) }
    let(:mail) { UserMailer.form_feedback(form_id: form.id, email: user.email) }

    it 'renders the headers' do
      expect(mail.subject).to eq("How was your Touchpoints experience with form #{form.name}?")
      expect(mail.to).to eq([user.email] + ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(','))
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('Please take this short survey to provide feedback regarding the Touchpoints application and/or the Touchpoints team')
      expect(mail.body.encoded).to include("https://touchpoints.app.cloud.gov/touchpoints/522e395c/submit?location_code=#{form.short_uuid}")
      expect(mail.body.encoded).to include(admin_form_url(form))
    end
  end
end
