# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubmissionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:form) { FactoryBot.create(:form, organization:, user: admin) }
  let!(:user_role) { FactoryBot.create(:user_role, user: admin, form:, role: UserRole::Role::FormManager) }

  let(:valid_attributes) do
    {
      form_id: form.id,
      answer_01: 'Test body text',
      answer_02: 'Test First Name',
      answer_03: 'Test Last name',
      answer_04: 'test_email@lvh.me',
    }
  end

  let(:invalid_attributes) do
    {
      answer_01: nil,
      answer_02: 'James',
      answer_03: 'Madison',
      answer_04: nil,
    }
  end

  let(:valid_session) { {} }

  before do
    sign_in(admin)
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested submission' do
      submission = Submission.create! valid_attributes
      expect do
        delete :destroy, params: { id: submission.to_param, form_id: form.short_uuid }, session: valid_session, format: :js
      end.to change(Submission, :count).by(-1)
    end

    it 'redirects to the submissions list' do
      submission = Submission.create! valid_attributes
      delete :destroy, params: { id: submission.to_param, form_id: form.short_uuid }, session: valid_session, format: :js
      expect(response).to render_template(:destroy)
    end
  end

  describe 'POST #flag' do
    before do
      @submission = Submission.create! valid_attributes
      post :flag, format: :js, params: { id: @submission.to_param, form_id: form.short_uuid }, session: valid_session
      @submission.reload
    end

    it 'flags the submission' do
      expect(@submission.flagged).to be true
    end
  end

  describe 'POST #unflag' do
    before do
      @submission = Submission.create! valid_attributes.merge!({ flagged: true })
      expect(@submission.flagged).to be true

      post :unflag, format: :js, params: { id: @submission.to_param, form_id: form.short_uuid }, session: valid_session
      @submission.reload
    end

    it 'unflags the submission' do
      expect(@submission.flagged).to be false
    end
  end
end
