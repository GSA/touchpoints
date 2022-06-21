# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::FormsController, type: :controller do
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
        let(:form) { FactoryBot.create(:form, :with_responses, user:, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :index, format: :json, params: { 'API_KEY' => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return an array of forms' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Array)
          expect(@parsed_response['data'].size).to eq(1)
          expect(@parsed_response['data'].first.class).to be(Hash)
          expect(@parsed_response['data'].first['id']).to eq(form.id.to_s)
        end

        it "return a form's questions" do
          relationships = @parsed_response['data'].first['relationships']
          expect(relationships.keys).to include('questions')
        end

        it "return a form's submissions" do
          relationships = @parsed_response['data'].first['relationships']
          expect(relationships.keys).to_not include('submissions')
        end
      end
    end

    describe '#show' do
      context 'passing a valid API_KEY' do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user:, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
          @parsed_response = JSON.parse(response.body)
        end

        it 'return an array of forms' do
          expect(response.status).to eq(200)
          expect(@parsed_response['data'].class).to be(Hash)
          expect(@parsed_response['data']['attributes']['name']).to eq(form.name)
          expect(@parsed_response['data']['relationships']['submissions']['data'].class).to eq(Array)
          expect(@parsed_response['data']['relationships']['submissions']['data'].size).to eq(3)
        end

        it "return a form's questions" do
          relationships = @parsed_response['data']['relationships']
          expect(relationships.keys).to include('questions')
        end

        it "return a form's submissions" do
          relationships = @parsed_response['data']['relationships']
          expect(relationships.keys).to include('submissions')
        end
      end

      context 'paging' do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user:, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

        before do
          user.update(api_key: TEST_API_KEY)
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        end

        it 'returns an array of forms with default page number and size' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(3)
          expect(parsed_response['links']['first']).not_to be_nil
          expect(parsed_response['links']['prev']).to be_nil
          expect(parsed_response['links']['next']).to be_nil
          expect(parsed_response['links']['last']).not_to be_nil
        end

        it 'returns an array of forms with page 1 of 2 results' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, page: 0, size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(2)
          expect(parsed_response['links']['first']).not_to be_nil
          expect(parsed_response['links']['prev']).to be_nil
          expect(parsed_response['links']['next']).not_to be_nil
          expect(parsed_response['links']['last']).not_to be_nil
        end

        it 'returns an array of forms with page 2 with 1 result' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, page: 1, size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(1)
          expect(parsed_response['links']['first']).not_to be_nil
          expect(parsed_response['links']['prev']).not_to be_nil
          expect(parsed_response['links']['next']).to be_nil
          expect(parsed_response['links']['last']).not_to be_nil
        end

        it 'returns an array of forms with page 3 with 0 results' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, page: 2, size: 2 }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(0)
          expect(parsed_response['links']['first']).not_to be_nil
          expect(parsed_response['links']['prev']).not_to be_nil
          expect(parsed_response['links']['next']).to be_nil
          expect(parsed_response['links']['last']).not_to be_nil
        end
      end

      context 'date_filter' do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :with_responses, user:, organization: user.organization) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

        before do
          user.update(api_key: TEST_API_KEY)
          form.submissions[0].created_at = 2.days.ago
          form.submissions[0].save
          form.submissions[1].created_at = 1.day.ago
          form.submissions[1].save
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
        end

        it 'returns an array of forms with date filter defaults' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(3)
        end

        it 'returns an array of forms with submissions which occurred during the past day' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, start_date: Date.today.strftime('%Y-%m-%d'), end_date: 1.day.from_now.strftime('%Y-%m-%d') }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(1)
        end

        it 'returns an array of forms with submissions which occurred during the past two days' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, start_date: 1.day.ago.strftime('%Y-%m-%d'), end_date: 1.day.from_now.strftime('%Y-%m-%d') }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(2)
        end

        it 'returns an array of forms with submissions which occurred during the past week' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, start_date: 7.days.ago.strftime('%Y-%m-%d'), end_date: 1.day.from_now.strftime('%Y-%m-%d') }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(3)
        end

        it 'returns an array of forms with submissions which occurred during the past week with paging' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, page: 0, size: 2, start_date: 7.days.ago.strftime('%Y-%m-%d'), end_date: 1.day.from_now.strftime('%Y-%m-%d') }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(parsed_response['data']['relationships']['submissions']['data'].size).to eq(2)
        end

        it 'returns an invalid input response for a bad date input' do
          get :show, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, start_date: 'Foo', end_date: 7.days.from_now.strftime('%Y-%m-%d') }
          parsed_response = JSON.parse(response.body)
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
