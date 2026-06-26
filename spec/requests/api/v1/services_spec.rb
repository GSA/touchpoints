# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/services', type: :request do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization: user.organization) }
  let!(:service) { FactoryBot.create(:service, organization: user.organization, service_provider:, service_owner_id: user.id) }

  before do
    disable_http_basic_auth
  end

  path '/services' do
    get('List services') do
      description 'Returns a list of services registered in Touchpoints.'
      tags 'Services'
      produces 'application/json'
      security [{ api_key: [] }]
      parameter name: 'hisp', in: :query, type: :integer, required: false,
                description: 'If set to 1, returns only HISP services. If not set or set to 0, returns all services.'
      
      response(200, 'successful') do
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/ServiceResource',
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

  path '/services/{id}' do
    get('Show service') do
      description 'Returns details for the given service.'
      tags 'Services'
      produces 'application/json'
      security [{ api_key: [] }]
      parameter name: 'id', in: :path, type: :integer, description: 'ID of the service'

      response(200, 'successful') do
        let(:id) { service.id }
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: { '$ref': '#/components/schemas/ServiceResource' },
               }

        run_test!
      end
    end
  end
end
