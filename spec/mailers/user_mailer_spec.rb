# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'submission_notification' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, organization:, user:) }
    let!(:submission) { FactoryBot.create(:submission, form:) }
    let(:mail) { UserMailer.submission_notification(submission_id: submission.id, emails: [user.email]) }

    it 'renders the headers' do
      expect(mail.subject).to eq("New Submission to #{submission.form.name}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Touchpoints.gov Response Notification')
      expect(mail.body.encoded).to match("New feedback has been submitted to your form, #{submission.form.name}.")
    end
  end

  describe 'submission_digest' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, organization:, user:) }
    let!(:submission) { FactoryBot.create(:submission, form:) }
    let(:begin_day) { 1.day.ago }
    let(:mail) { UserMailer.submissions_digest(form.id, begin_day) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("New Submissions to #{form.name} since #{begin_day}")
      expect(mail.to).to eq(form.notification_emails.split)
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Notification of feedback received since #{@begin_day}")
      expect(mail.body.encoded).to match("1 feedback responses have been submitted to your form, #{form.name}, since #{begin_day}")
    end
  end

  describe 'form_status_changed' do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, organization:, user:) }
    let(:mail) { UserMailer.form_status_changed(form:, action: 'published') }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Touchpoints form #{form.name} published")
      expect(mail.to).to eq(ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(','))
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Form status changed')
      expect(mail.body.encoded).to match('status changed to published')
    end
  end

  describe 'quarterly_performance_update' do
    let!(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, organization:) }
    let!(:collection) { FactoryBot.create(:collection, user:) }
    let(:mail) { UserMailer.quarterly_performance_notification(collection_id: collection.id) }

    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Quarterly Performance Data Collection Ready: #{collection.name}")
      expect(mail.to).to eq([collection.user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Quarterly Performance Notification')
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
      expect(mail.subject).to eq("Your account is scheduled to be deactivated in #{active_days} days due to inactivity")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch('TOUCHPOINTS_EMAIL_SENDER')])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Account deactivation scheduled in #{active_days} days.")
      expect(mail.body.encoded).to match("Your account is scheduled to be deactivated in #{active_days} days due to inactivity.")
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
      expect(mail.body.encoded).to match('Hi')
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
      expect(mail.body.encoded).to match('Hi')
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
      expect(mail.body.encoded).to match('New user account created')
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
      expect(mail.body.encoded).to match('New user added to organization')
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
      expect(mail.body.encoded).to match('New user account creation failed')
    end
  end
end
