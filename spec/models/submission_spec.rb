# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model do
  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user2) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.build(:form, :custom, organization:, user: admin, notification_emails: "#{admin.email}, second@example.gov") }
  let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: user2, form:) }
  let(:submission) { FactoryBot.create(:submission, form:) }

  describe '#send_notifications' do
    before do
      ENV['ENABLE_EMAIL_NOTIFICATIONS'] = 'true'
    end

    it 'returns a DeliveryJob' do
      expect(submission.send_notifications.class).to eq(ActionMailer::MailDeliveryJob)
    end

    it 'to Form.notification_emails' do
      expect(submission.send_notifications.arguments[3][:args].first[:emails]).to eq(form.notification_emails.split(','))
      expect(submission.send_notifications.arguments[3][:args].first[:emails]).to_not include(user2.email)
    end
  end

  describe 'uuid' do
    it 'has UUID set by default' do
      expect(submission.uuid).to be_present
      expect(submission.uuid.length).to eq(36)
    end

    describe 'uniqueness' do
      let(:submission2) { FactoryBot.create(:submission, form:) }

      before do
        submission.uuid = submission2.uuid
        submission.save
      end

      it 'throws error when trying to duplicate UUID' do
        expect(submission.errors.messages).to eq({ uuid: ['has already been taken'] })
      end
    end
  end
end
