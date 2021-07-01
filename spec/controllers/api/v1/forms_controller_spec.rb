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
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
          get :index, format: :json, params: { "API_KEY" => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it "return an array of forms" do
          expect(response.status).to eq(200)
          expect(@parsed_response["data"].class).to be(Array)
          expect(@parsed_response["data"].size).to eq(1)
          expect(@parsed_response["data"].first.class).to be(Hash)
          expect(@parsed_response["data"].first["id"]).to eq(form.id.to_s)
        end

        it "return a form's questions" do
          relationships = @parsed_response["data"].first["relationships"]
          expect(relationships.keys).to include("questions")
        end

        it "return a form's submissions" do
          relationships = @parsed_response["data"].first["relationships"]
          expect(relationships.keys).to_not include("submissions")
        end
      end
    end

    describe "#show" do
      context "passing a valid API_KEY" do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user: user, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: user, form: form) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it "return an array of forms" do
          expect(response.status).to eq(200)
          expect(@parsed_response["data"].class).to be(Hash)
          expect(@parsed_response["data"]["attributes"]["name"]).to eq(form.name)
          expect(@parsed_response["data"]["relationships"]["submissions"]["data"].class).to eq(Array)
          expect(@parsed_response["data"]["relationships"]["submissions"]["data"].size).to eq(3)
        end

        it "return a form's questions" do
          relationships = @parsed_response["data"]["relationships"]
          expect(relationships.keys).to include("questions")
        end

        it "return a form's submissions" do
          relationships = @parsed_response["data"]["relationships"]
          expect(relationships.keys).to include("submissions")
        end
      end

      context "paging" do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user: user, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: user, form: form) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch("API_HTTP_USERNAME"), ENV.fetch("API_HTTP_PASSWORD"))
        end

        it "returns an array of forms with default page number and size" do
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["data"]["relationships"]["submissions"]["data"].size).to eq(3)
        end

        it "returns an array of forms with page 1 of 2 results" do
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key, page: 0, page_size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["data"]["relationships"]["submissions"]["data"].size).to eq(2)
        end

        it "returns an array of forms with page 2 with 1 result" do
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key, page: 1, page_size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["data"]["relationships"]["submissions"]["data"].size).to eq(1)
        end

        it "returns an array of forms with page 3 with 0 results" do
          get :show, format: :json, params: { id: form.short_uuid, "API_KEY" => user.api_key, page: 2, page_size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response["data"]["relationships"]["submissions"]["data"].size).to eq(0)
        end
      end
    end
  end
end
