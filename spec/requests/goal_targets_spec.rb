 require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/goal_targets", type: :request do
  
  # GoalTarget. As you add validations to GoalTarget, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      GoalTarget.create! valid_attributes
      get goal_targets_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      goal_target = GoalTarget.create! valid_attributes
      get goal_target_url(goal_target)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_goal_target_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      goal_target = GoalTarget.create! valid_attributes
      get edit_goal_target_url(goal_target)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new GoalTarget" do
        expect {
          post goal_targets_url, params: { goal_target: valid_attributes }
        }.to change(GoalTarget, :count).by(1)
      end

      it "redirects to the created goal_target" do
        post goal_targets_url, params: { goal_target: valid_attributes }
        expect(response).to redirect_to(goal_target_url(GoalTarget.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new GoalTarget" do
        expect {
          post goal_targets_url, params: { goal_target: invalid_attributes }
        }.to change(GoalTarget, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post goal_targets_url, params: { goal_target: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested goal_target" do
        goal_target = GoalTarget.create! valid_attributes
        patch goal_target_url(goal_target), params: { goal_target: new_attributes }
        goal_target.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the goal_target" do
        goal_target = GoalTarget.create! valid_attributes
        patch goal_target_url(goal_target), params: { goal_target: new_attributes }
        goal_target.reload
        expect(response).to redirect_to(goal_target_url(goal_target))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        goal_target = GoalTarget.create! valid_attributes
        patch goal_target_url(goal_target), params: { goal_target: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested goal_target" do
      goal_target = GoalTarget.create! valid_attributes
      expect {
        delete goal_target_url(goal_target)
      }.to change(GoalTarget, :count).by(-1)
    end

    it "redirects to the goal_targets list" do
      goal_target = GoalTarget.create! valid_attributes
      delete goal_target_url(goal_target)
      expect(response).to redirect_to(goal_targets_url)
    end
  end
end
