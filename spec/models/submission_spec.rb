# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model do
  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user2) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :single_question, organization:, notification_emails: "#{admin.email}, second@example.gov") }
  let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: user2, form:) }
  let(:submission) { FactoryBot.create(:submission, form:) }

  describe "default scope" do
    let!(:active_submission) { Submission.create!(deleted: false, archived: false, flagged: false, spam: false, form:) }
    let!(:deleted_submission) { Submission.create!(deleted: true, archived: false, flagged: false, spam: false, form:) }
    let!(:archived_submission) { Submission.create!(deleted: false, archived: true, flagged: false, spam: false, form:) }
    let!(:flagged_submission) { Submission.create!(deleted: false, archived: false, flagged: true, spam: false, form:) }
    let!(:spam_submission) { Submission.create!(deleted: false, archived: false, flagged: false, spam: true, form:) }
    let!(:both_deleted_and_archived) { Submission.create!(deleted: true, archived: true, flagged: false, spam: false, form:) }
    let!(:all_false) { Submission.create!(deleted: false, archived: false, flagged: false, spam: false, form:) }

    it "excludes deleted submissions" do
      expect(Submission.all).not_to include(deleted_submission)
    end

    it "excludes archived submissions" do
      expect(Submission.all).not_to include(archived_submission)
    end

    it "excludes flagged submissions" do
      expect(Submission.all).not_to include(flagged_submission)
    end

    it "excludes spam submissions" do
      expect(Submission.all).not_to include(spam_submission)
    end

    it "excludes submissions that are both deleted and archived" do
      expect(Submission.all).not_to include(both_deleted_and_archived)
    end

    it "includes only active submissions (not deleted, archived, flagged, or spam)" do
      expect(Submission.all).to contain_exactly(active_submission, all_false)
    end
  end

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

  describe 'spam_score' do
    it 'defaults to 0' do
      expect(submission.spam_score).to eq(0)
    end
  end
end
