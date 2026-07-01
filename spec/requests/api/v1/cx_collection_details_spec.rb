# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/cx_collection_details', type: :request do
  include_context 'rswag deterministic examples'

  let!(:organization) { FactoryBot.create(:documented_organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:documented_service_provider, organization:) }
  let!(:service) { FactoryBot.create(:documented_service, organization:, service_provider:, service_owner_id: user.id) }
  let!(:cx_collection) { FactoryBot.create(:documented_cx_collection, organization:, user:, service_provider:, service:) }
  let!(:cx_collection_detail) { FactoryBot.create(:documented_cx_collection_detail, cx_collection:, service:) }

  before do
    simulate_api_gateway_request
  end

  path '/cx_collection_details' do

    get('List CX collection details') do
      description 'Returns a list of all CX collection details.'
      tags 'CX Collections'
      produces 'application/json'
      security [{ api_key: [] }]
      
      response(200, 'successful') do
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/CxCollectionDetailResource',
                   },
                 },
               }

        after do |example|
          capture_example example
        end

        run_test! do |response|
          data = JSON.parse(response.body)['data']
          expect(data).not_to be_empty
        end
      end
    end
  end
end
