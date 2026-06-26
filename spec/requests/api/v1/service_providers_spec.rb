# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/service_providers', type: :request do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization: user.organization) }

  before do
    disable_http_basic_auth
  end

  path '/service_providers' do
    get('List service providers') do
      description 'Returns a list of service providers registered in Touchpoints.'
      tags 'Services'
      produces 'application/json'
      security [{ api_key: [] }]
      
      response(200, 'successful') do
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/ServiceProviderResource',
                   },
                 },
               }

        run_test! do |response|
          data = JSON.parse(response.body)['data']
          expect(data).not_to be_empty
        end
      end
    end
  end
end
