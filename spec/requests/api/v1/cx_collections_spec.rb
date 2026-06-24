# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/cx_collections', type: :request do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }
  let!(:cx_collection) { FactoryBot.create(:cx_collection, organization:, user:, service_provider:, service:) }

  before do
    disable_http_basic_auth
  end

  path '/v1/cx_collections' do
    get('List CX collections') do
      description 'Returns a list of all CX collections.'
      tags 'CX Collections'
      produces 'application/json'
      security [{ api_key: [] }]
      parameter name: 'all', in: :query, type: :integer, required: false,
                description: 'If set to 1, returns all CX collections. If not set or set to 0, returns only published CX collections.'
      
      response(200, 'successful') do
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/CxCollectionResource',
                   },
                 },
               }

        let(:all) { 1 }

        run_test! do |response|
          data = JSON.parse(response.body)['data']
          expect(data).not_to be_empty
        end
      end
    end
  end
end
