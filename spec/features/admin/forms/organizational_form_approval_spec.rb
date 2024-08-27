# frozen_string_literal: true

require 'rails_helper'

feature 'Form - Organization Form Approval feature', js: true do
  let(:organization) { FactoryBot.create(:organization, form_approval_enabled: true) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:organizational_form_approver) { FactoryBot.create(:user, organization: organization, organizational_form_approver: true) }
  let!(:form) { FactoryBot.create(:form, organization: organization) }
  let!(:draft_form) { FactoryBot.create(:form, organization: organization, aasm_state: :created) }
  let!(:submitted_form) { FactoryBot.create(:form, organization: organization, aasm_state: :submitted) }
  let!(:user) { FactoryBot.create(:user, organization: organization) }

  context 'as Admin' do
    before do
      login_as(admin)
    end

    describe 'message text describing organizational form approver' do
      context 'a draft form is Submitted for approval' do
        before do
          visit admin_form_path(draft_form)
        end

        it 'displays text and Organization Form approver emails' do
          expect(page).to have_text("For any questions about Organizational Form Approval")
          expect(page).to have_text("please contact #{organization.name}'s form approver")
          expect(page).to have_link(organizational_form_approver.email)

          expect(page).to have_link("Submit for Organizational Approval")
        end
      end
    end

    describe 'message text describing organizational form approver' do
      context 'a draft form is Submitted for approval' do
        before do
          visit admin_form_path(submitted_form)
        end

        it 'displays text and Organization Form approver emails' do
          expect(page).to have_text("For any questions about Organizational Form Approval")
          expect(page).to have_text("please contact #{organization.name}'s form approver")
          expect(page).to have_link(organizational_form_approver.email)

          expect(page).to have_button("Approve")
        end
      end
    end
  end
end
