# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::WebsitesController, type: :controller do
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
        let!(:website) { FactoryBot.create(:website, organization: user.organization, aasm_state: :published) }
        let!(:website2) { FactoryBot.create(:website, organization: user.organization, aasm_state: :published) }
        let!(:website3) { FactoryBot.create(:website, organization: user.organization) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return an array of published service providers' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Array)
          expect(@parsed_response['data'].size).to eq(2)
          expect(@parsed_response['data'].first.class).to be(Hash)
          expect(@parsed_response['data'].first['type']).to eq("websites")

          expect(@parsed_response['data'].first['attributes'].keys).to include("domain")
          expect(@parsed_response['data'].first['attributes'].keys).to include("organization_id")
          expect(@parsed_response['data'].first['attributes'].keys).to include("organization_name")
          expect(@parsed_response['data'].first['attributes'].keys).to include("backlog_tool")
          expect(@parsed_response['data'].first['attributes'].keys).to include("backlog_url")
        end
      end
    end
  end
end
