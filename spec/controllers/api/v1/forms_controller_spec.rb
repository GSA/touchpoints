require 'rails_helper'

describe Api::V1::FormsController, type: :controller do
  describe "unauthenticated request" do
    before do
      get :index
    end

    it "get access denied due to HTTP Basic Auth" do
      expect(response.status).to eq(401)
    end
  end

  describe "authenticated request, using HTTP_AUTH" do
    describe "without passing ?API_KEY" do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
        get :index, format: :json
      end

      it "get access denied due to HTTP Basic Auth" do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(400)
        expect(parsed_response["error"]["message"]).to eq("Invalid request. No ?API_KEY= was passed in.")
      end
    end

    describe "passing an invalid API_KEY" do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
        get :index, format: :json, params: { "API_KEY" => "INVALID_KEY" }
      end

      it "get access denied due to HTTP Basic Auth" do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(401)
        expect(parsed_response["error"]["message"]).to eq("The API_KEY INVALID_KEY is not valid.")
      end
    end

    describe "#index" do
      context "passing a valid API_KEY" do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user: user, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: user, form: form) }

        before do
          user.update_attribute(:api_key, TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
          get :index, format: :json, params: { "API_KEY" => user.api_key }
        end

        it "return an array of forms" do
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["forms"].class).to be(Array)
          expect(parsed_response["forms"].size).to eq(1)
        end
      end
    end


    describe "#show" do
      context "passing a valid API_KEY" do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user: user, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: user, form: form) }

        before do
          user.update_attribute(:api_key, TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key }
        end

        it "return an array of forms" do
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["form"].class).to be(Hash)
          expect(parsed_response["form"]["name"]).to eq(form.name)
          expect(parsed_response["responses"].class).to eq(Array)
          expect(parsed_response["responses"].size).to eq(3)
        end
      end
    end
  end
end
