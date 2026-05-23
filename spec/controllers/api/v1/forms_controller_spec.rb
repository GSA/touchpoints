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
      let!(:organization) { FactoryBot.create(:organization) }
      let!(:user) { FactoryBot.create(:user, organization: organization) }
      let!(:user2) { FactoryBot.create(:user, organization: organization) }
      let(:form) { FactoryBot.create(:form, :single_question, :with_responses, organization: user.organization) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

      let!(:another_form) { FactoryBot.create(:form, :single_question, :with_responses, organization: user2.organization) }
      let!(:organizational_admin_user) { FactoryBot.create(:user, organization: organization, organizational_admin: true) }

      context "Organizational Admin user" do
        context 'passing a valid API_KEY' do
          before do
            organizational_admin_user.update(api_key: TEST_API_KEY)
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
            get :index, format: :json, params: { 'API_KEY' => organizational_admin_user.api_key }
            @parsed_response = JSON.parse(response.body)
          end

          it 'return an array of all Organization forms' do
            expect(response.status).to eq(200)
            expect(@parsed_response['data'].class).to be(Array)
            expect(@parsed_response['data'].size).to eq(2)
            expect(@parsed_response['data'].first.class).to be(Hash)
            expect(@parsed_response['data'].collect { |i| i["id"] }).to include(form.id.to_s)
            expect(@parsed_response['data'].collect { |i| i["id"] }).to include(another_form.id.to_s)
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

      context "user" do
        context 'passing a valid API_KEY' do
          before do
            user.update(api_key: TEST_API_KEY)
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
            get :index, format: :json, params: { 'API_KEY' => user.api_key }
            @parsed_response = JSON.parse(response.body)
          end

          it "return an array of the user's forms" do
            expect(response.status).to eq(200)
            expect(@parsed_response['data'].class).to be(Array)
            expect(@parsed_response['data'].size).to eq(1)
            expect(@parsed_response['data'].first.class).to be(Hash)
            expect(@parsed_response['data'].first['id']).to eq(form.id.to_s)
            expect(@parsed_response['data'].collect { |i| i["id"] }).to include(form.id.to_s)
            expect(@parsed_response['data'].collect { |i| i["id"] }).to_not include(another_form.id.to_s)
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

    end

    describe '#show' do
      context 'passing a valid API_KEY' do
        let!(:user) { FactoryBot.create(:user) }
        let(:form) { FactoryBot.create(:form, :single_question, :with_responses, organization: user.organization) }
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
        let(:form) { FactoryBot.create(:form, :single_question, :with_responses, organization: user.organization) }
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
        let(:form) { FactoryBot.create(:form, :single_question, :with_responses, organization: user.organization) }
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

    describe 'responses#index' do
      let!(:user) { FactoryBot.create(:user) }
      let(:form) do 
        FactoryBot.create(:form, :single_question, organization: user.organization) do |form|
          i = 0
          7.times { FactoryBot.create(:submission, form: form, created_at: 10.days.ago, answer_01: (i += 1)) }
          8.times { FactoryBot.create(:submission, form: form, created_at: 1.day.ago, answer_01: (i += 1)) }
        end
      end
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

      before do
        user.update(api_key: TEST_API_KEY)
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV.fetch('API_HTTP_USERNAME'), ENV.fetch('API_HTTP_PASSWORD'))
      end

      it 'only shows responses for forms user can see' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
        expect(response.status).to eq(200)

        user_role.destroy
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
        expect(response.status).to eq(404)
      end

      it 'ignores invalid query params' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 page: 3, style: 'fast' }
        expect(response.status).to eq(200)
        expect(response.parsed_body['meta']['current_page']).to eq(1)
      end

      it 'sets defaults for page_number and page_size' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
        expect(response.status).to eq(200)
        expect(response.parsed_body['meta']['current_page']).to eq(1)
        expect(response.parsed_body['meta']['page_size']).to eq(500)
      end

      it 'limits page_size to 5000' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, 'page[size]' => 5_001 }
        expect(response.status).to eq(400)
        expect(response.parsed_body['error']).to eq({ 'message' => 'max page size is 5000', 'status' => 400 })
      end

      it 'errors on invalid date format' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key, start_date: 'not-a-date' }
        expect(response.status).to eq(400)
        expect(response.parsed_body['error']).to eq("message" => "invalid date format, should be 'YYYY-MM-DD'", "status" => 400)
      end

      it 'returns items based on page_number, page_size and date filters' do
        # Form has 15 responses but only 8 created within date range
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 1, 'page[size]' => 5,
                                                 'start_date' => 3.days.ago.strftime('%Y-%m-%d') }

        expect(response.status).to eq(200)
        data = response.parsed_body['data']
        expect(data.size).to eq(5)
        expect(data.map { |item| item['attributes']['answer_01'] }).to eq(["8", "9", "10", "11", "12"])

        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 2, 'page[size]' => 5,
                                                 'start_date' => 3.days.ago.strftime('%Y-%m-%d') }
        expect(response.status).to eq(200)
        data = response.parsed_body['data']
        expect(data.size).to eq(3)
        expect(data.map { |item| item['attributes']['answer_01'] }).to eq(["13", "14", "15"])
      end

      it 'returns paging metadata based on page_number, page_size and date filters' do
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 1, 'page[size]' => 5,
                                                 'start_date' => 3.days.ago.strftime('%Y-%m-%d') }

        expect(response.status).to eq(200)
        meta = response.parsed_body['meta']
        expect(meta).to eq({ "current_page" => 1, "page_size" => 5, "total_count" => 8, "total_pages" => 2 })

        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 2, 'page[size]' => 5,
                                                 'start_date' => 3.days.ago.strftime('%Y-%m-%d') }

        expect(response.status).to eq(200)
        meta = response.parsed_body['meta']
        expect(meta).to eq({ "current_page" => 2, "page_size" => 5, "total_count" => 8, "total_pages" => 2 })
      end

      it 'returns links based on page_number, page_size and date filters' do
        start_date = 3.days.ago.strftime('%Y-%m-%d')
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 1, 'page[size]' => 5,
                                                 'start_date' => start_date }

        expect(response.status).to eq(200)
        expect(response.parsed_body['links']).to eq(
                                              {
                                                "first" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "last" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "next" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "prev" => nil,
                                                "self" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                              }
                                            )

        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 2, 'page[size]' => 5,
                                                 'start_date' => start_date }
        expect(response.status).to eq(200)
        expect(response.parsed_body['links']).to eq(
                                              {
                                                "first" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "last" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "next" => nil,
                                                "prev" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "self" => "http://test.host/api/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                              },
                                            )
      end

      it 'returns links pointing to api gateway when appropriate' do
        request.headers['X-Api-Umbrella-Request-Id'] = 'aelqdj9lfoe7c2itheg0'

        start_date = 3.days.ago.strftime('%Y-%m-%d')
        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key,
                                                 'page[number]' => 1, 'page[size]' => 5,
                                                 'start_date' => start_date }
        expect(response.status).to eq(200)
        expect(response.parsed_body['links']).to eq(
                                              {
                                                "first" => "https://api-gateway.example.gov/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "last" => "https://api-gateway.example.gov/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "next" => "https://api-gateway.example.gov/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=2&page%5Bsize%5D=5&start_date=#{start_date}",
                                                "prev" => nil,
                                                "self" => "https://api-gateway.example.gov/v1/forms/#{form.short_uuid}/responses.json?API_KEY=#{TEST_API_KEY}&page%5Bnumber%5D=1&page%5Bsize%5D=5&start_date=#{start_date}",
                                              },
                                            )
      end

      it 'does not return deleted responses' do
        submission = form.submissions.first
        submission.assign_attributes(deleted: true, deleted_at: Time.zone.now)
        submission.save(validate: false)

        get :responses, format: :json, params: { id: form.short_uuid, 'API_KEY' => user.api_key }
        expect(response.status).to eq(200)
        expect(response.parsed_body['data'].size).to eq(14)
      end
    end
  end
end
