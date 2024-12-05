# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CxResponsesController, type: :controller do
  describe 'unauthenticated request' do
    before do
      get :index
    end

    it 'get access denied due to HTTP Basic Auth' do
      expect(response.status).to eq(401)
    end
  end

  describe 'authenticated request, using HTTP_AUTH' do
    describe 'without passing ?API_KEY' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        get :index, format: :json
      end

      it 'get access denied due to HTTP Basic Auth' do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(400)
        expect(parsed_response['error']['message']).to eq('Invalid request. No ?API_KEY= was passed in.')
      end
    end

    describe 'passing an invalid API_KEY' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        get :index, format: :json, params: { 'API_KEY' => 'INVALID_KEY' }
      end

      it 'get access denied due to HTTP Basic Auth' do
        parsed_response = JSON.parse(response.body)
        expect(response.status).to eq(401)
        expect(parsed_response['error']['message']).to eq('The API_KEY INVALID_KEY is not valid.')
      end
    end

    context "with uploads" do
      let!(:user) { FactoryBot.create(:user, api_key: TEST_API_KEY) }
      let!(:organization1) { FactoryBot.create(:organization) }
      let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization1) }
      let!(:service) { FactoryBot.create(:service, organization: organization1, service_provider: service_provider, service_owner_id: user.id) }
      let!(:cx_collection) { FactoryBot.create(:cx_collection, organization: organization1, service_provider: service_provider, service: service, user: user) }
      let!(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }
      let!(:cx_collection_detail_upload) { cx_collection_detail.cx_collection_detail_uploads.first }
      let!(:cx_response) { CxResponse.order(:id).first }

      describe '#index' do
        before do
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key }
        end

        it 'return a default paginated array of cx_responses' do
          parsed_response = JSON.parse(response.body)
          expect(cx_collection_detail.cx_responses.count).to eq(1000)

          expect(response.status).to eq(200)
          expect(parsed_response['data'].class).to be(Array)
          expect(parsed_response['data'].size).to eq(500)
          expect(parsed_response['data'].first.class).to be(Hash)
          expect(parsed_response['data'].first["type"]).to eq("cx_responses")
          expect(parsed_response['data'].first['id'].to_s).to eq(cx_response.id.to_s)
        end
      end

      describe 'pagination' do
        before do
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key, "page[size]" => 100, "page[number]" => 10 }
        end

        it 'return the last paginated array of 100 cx_responses' do
          expect(cx_collection_detail.cx_responses.count).to eq(1000)
          parsed_response = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(parsed_response['data'].class).to be(Array)
          expect(parsed_response['data'].size).to eq(100)
          expect(parsed_response['data'].last.class).to be(Hash)
          expect(parsed_response['data'].last["type"]).to eq("cx_responses")
          expect(parsed_response['data'].last['id'].to_s).to eq(CxResponse.last.id.to_s)
        end
      end

      describe "GET #index with date filters" do
        let!(:response_in_range) { create(:cx_response, cx_collection_detail:, cx_collection_detail_upload:, created_at: Date.parse("2024-10-15")) }
        let!(:response_out_of_range) { create(:cx_response, cx_collection_detail:, cx_collection_detail_upload:, created_at: Date.parse("2023-09-01")) }

        before do
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        end

        it "returns only responses within the specified date range" do
          get :index, params: {
            start_date: "2024-10-01",
            end_date: "2025-09-30",
            page: { size: 5000 },
            'API_KEY' => user.api_key,
            format: :json
          }

          expect(response).to have_http_status(:success)

          parsed_response = JSON.parse(response.body)
          response_ids = parsed_response["data"].map { |r| r["id"].to_i }

          expect(response_ids).to include(response_in_range.id)
          expect(response_ids).not_to include(response_out_of_range.id)
        end

        it "returns an error for invalid date format" do
          get :index, params: { start_date: "invalid-date", end_date: "2023-10-31", 'API_KEY' => user.api_key, format: :json }

          expect(response).to have_http_status(:bad_request)

          parsed_response = JSON.parse(response.body)
          expect(parsed_response["error"]["message"]).to eq("invalid date format, should be 'YYYY-MM-DD'")
        end
      end
    end

  end
end
