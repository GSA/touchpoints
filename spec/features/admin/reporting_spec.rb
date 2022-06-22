# frozen_string_literal: true

require 'rails_helper'

feature 'Reporting', js: true do
  let(:organization) { FactoryBot.create(:organization) }

  context 'as Admin' do
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }

    describe '#no_submissions' do
      before do
        login_as admin
      end

      it 'creates the report' do
        visit admin_no_submissions_path
        expect(page).to have_content('Live Surveys Without Submissions by Agency')
      end

      it 'does not appear on report when not live' do
        form.archive!
        expect(page).not_to have_content(form.name)
      end

      it 'appears on report when live and no responses' do
        visit admin_no_submissions_path
        expect(page).to have_content(form.name)
      end

      it 'does not appear on report when live and has responses < 90 days old' do
        submission = FactoryBot.create(:submission, form:)
        visit admin_no_submissions_path
        expect(page).not_to have_content(form.name)
      end

      it 'appears on report when live and has responses > 90 days old' do
        submission = FactoryBot.create(:submission, form:)
        submission.update!(created_at: 100.days.ago)
        visit admin_no_submissions_path
        expect(page).to have_content(form.name)
      end
    end
  end
end
