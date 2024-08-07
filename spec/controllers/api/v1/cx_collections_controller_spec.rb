# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CxCollectionsController, type: :controller do
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

    describe '#index' do
      context 'passing a valid API_KEY' do
        let!(:user) { FactoryBot.create(:user) }
        let!(:organization) { FactoryBot.create(:organization) }
        let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
        let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }
        let!(:cx_collection) { FactoryBot.create(:cx_collection, organization:, user:, service_provider:, service:) }
        let!(:cx_collection1) { FactoryBot.create(:cx_collection, organization:, service_provider:, service:, aasm_state: :published) }
        let!(:cx_collection2) { FactoryBot.create(:cx_collection, organization:, service_provider:, service:, aasm_state: :published) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return an array of published cx collections' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Array)
          expect(@parsed_response['data'].size).to eq(2)
          expect(@parsed_response['data'].first.class).to be(Hash)
          expect(@parsed_response['data'].first["type"]).to eq("cx_collections")
          expect(@parsed_response['data'].first['id']).to eq(cx_collection1.id.to_s)
        end
      end
    end
  end
end
