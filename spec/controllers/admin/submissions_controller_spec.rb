# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubmissionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:form) { FactoryBot.create(:form, :single_question, organization:) }
  let!(:user_role) { FactoryBot.create(:user_role, user: admin, form:, role: UserRole::Role::FormManager) }
  let!(:questions) {
    FactoryBot.create(:question,
      form:,
      question_type: 'text_field',
      form_section: form.form_sections.first,
      answer_field: 'answer_02',
      position: 2,
      text: 'Two'
    )
    FactoryBot.create(:question,
      form:,
      question_type: 'text_field',
      form_section: form.form_sections.first,
      answer_field: 'answer_03',
      position: 3,
      text: 'Three'
    )
    FactoryBot.create(:question,
      form:,
      question_type: 'text_field',
      form_section: form.form_sections.first,
      answer_field: 'answer_04',
      position: 4,
      text: 'Four'
    )

  }

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

  describe "#status_params" do
    let(:submission) { FactoryBot.create(:submission, form:) }
    let(:valid_states) { Submission.aasm.states.map(&:name) }

    context "when a valid aasm_state is provided" do
      it "permits the parameter and returns it" do
        valid_state = valid_states.sample.to_s
        patch :update, params: { aasm_state: valid_state, form_id: submission.form.short_uuid, id: submission.id  }

        expect(response).to redirect_to(admin_form_submission_path(form, submission))
        expect(flash[:notice]).to eq('Response was successfully updated.')
      end
    end

    context "when aasm_state is missing" do
      it "raises an ActionController::ParameterMissing error" do
        expect {
          patch :update, params: { aasm_state: nil, form_id: submission.form.short_uuid, id: submission.id  }
        }.to raise_error(ActionController::ParameterMissing, "param is missing or the value is empty or invalid: aasm_state parameter is missing")
      end
    end

    context "when an invalid aasm_state is provided" do
      it "raises an ActionController::ParameterMissing error" do
        expect {
          patch :update, params: { aasm_state: "invalid_state", form_id: submission.form.short_uuid, id: submission.id  }
        }.to raise_error(ActionController::ParameterMissing, "param is missing or the value is empty or invalid: Invalid state: invalid_state")
      end
    end
  end

  describe 'DELETE #delete' do
    it 'deletes the requested submission' do
      submission = Submission.create! valid_attributes
      expect do
        delete :delete, params: { id: submission.to_param, form_id: form.short_uuid }, session: valid_session, format: :js
      end.to change { Submission.active.count }.by(-1)
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
    let(:submission) { FactoryBot.create(:submission, form:) }

    before do
      submission.update(flagged: true)
      expect(submission.flagged).to be true

      post :unflag, format: :js, params: { id: submission.to_param, form_id: form.short_uuid }, session: valid_session
      submission.reload
    end

    it 'unflags the submission' do
      expect(submission.flagged).to be false
    end
  end

  describe 'POST #bulk_update' do
    let!(:submission) { FactoryBot.create(:submission, form:) }
    let!(:submission2) { FactoryBot.create(:submission, form:) }
    let!(:submission3) { FactoryBot.create(:submission, form:) }

    describe "bulk_action=flag" do
      before do
        post :bulk_update, params: { submission_ids: Submission.all.collect(&:id), form_id: form.short_uuid, bulk_action: "flag" }, session: valid_session
      end

      it 'flags the submissions' do
        expect(response.status).to eq(302)
        expect(flash[:notice]).to eq("3 Submissions flagged.")
        expect(Submission.flagged.count).to eq(3)
      end
    end

    describe "bulk_action=archive" do
      before do
        post :bulk_update, params: { submission_ids: Submission.all.collect(&:id), form_id: form.short_uuid, bulk_action: "archive" }, session: valid_session
      end

      it 'archives the submissions' do
        expect(response.status).to eq(302)
        expect(flash[:notice]).to eq("3 Submissions archived.")
        expect(Submission.archived.count).to eq(3)
      end
    end

    describe "bulk_action=spam" do
      before do
        post :bulk_update, params: { submission_ids: Submission.all.collect(&:id), form_id: form.short_uuid, bulk_action: "spam" }, session: valid_session
      end

      it 'marks the submissions as spam' do
        expect(response.status).to eq(302)
        expect(flash[:notice]).to eq("3 Submissions marked as spam.")
        expect(Submission.marked_as_spam.count).to eq(3)
      end
    end

    describe "bulk_action=nil" do
      before do
        post :bulk_update, params: { submission_ids: Submission.all.collect(&:id), form_id: form.short_uuid }, session: valid_session
      end

      it 'is invalid' do
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq("Invalid action selected.")
      end
    end

    describe "submission_ids=nil" do
      before do
        post :bulk_update, params: { submission_ids: nil, form_id: form.short_uuid }, session: valid_session
      end

      it 'is invalid' do
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq("No Submissions selected.")
      end
    end
  end
end
