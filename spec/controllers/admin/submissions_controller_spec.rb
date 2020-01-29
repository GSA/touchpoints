require 'rails_helper'

RSpec.describe Admin::SubmissionsController, type: :controller do

  let(:admin) { FactoryBot.create(:user, :admin)}
  let!(:touchpoint) { FactoryBot.create(:touchpoint, :with_form) }
  let!(:user_role) { FactoryBot.create(:user_role, user: admin, touchpoint: touchpoint, role: UserRole::Role::TouchpointManager) }

  let(:valid_attributes) {
    {
      touchpoint_id: touchpoint.id,
      answer_01: "Test body text",
      answer_02: "Test First Name",
      answer_03: "Test Last name",
      answer_04: "test_email@lvh.me"
    }
  }

  let(:invalid_attributes) {
    {
      answer_01: nil,
      answer_02: "James",
      answer_03: "Madison",
      answer_04: nil
    }
  }

  let(:valid_session) { {} }

  before do
    sign_in(admin)
  end

  describe "DELETE #destroy" do
    it "destroys the requested submission" do
      submission = Submission.create! valid_attributes
      expect {
        delete :destroy, params: {id: submission.to_param, touchpoint_id: touchpoint.to_param }, session: valid_session
      }.to change(Submission, :count).by(-1)
    end

    it "redirects to the submissions list" do
      submission = Submission.create! valid_attributes
      delete :destroy, params: {id: submission.to_param, touchpoint_id: touchpoint.to_param }, session: valid_session
      expect(response).to redirect_to(admin_touchpoint_url(touchpoint))
    end
  end

  describe "POST #flag" do
    before do
      @submission = Submission.create! valid_attributes
      post :flag, params: {id: @submission.to_param, touchpoint_id: touchpoint.to_param }, session: valid_session
      @submission.reload
    end

    it "flags the submission" do
      expect(@submission.flagged).to be true
    end
  end

  describe "POST #unflag" do
    before do
      @submission = Submission.create! valid_attributes.merge!({ flagged: true })
      expect(@submission.flagged).to be true

      post :unflag, params: { id: @submission.to_param, touchpoint_id: touchpoint.to_param }, session: valid_session
      @submission.reload
    end

    it "unflags the submission" do
      expect(@submission.flagged).to be false
    end
  end
end
