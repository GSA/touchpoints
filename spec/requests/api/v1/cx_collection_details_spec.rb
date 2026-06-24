# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/cx_collection_details', type: :request do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization: user.organization, service_provider: service_provider, service_owner_id: user.id) }
  let!(:collection) { FactoryBot.create(:cx_collection, organization:, service:, service_provider: service_provider, quarter: 2, fiscal_year: 2024, aasm_state: :published) }
  let!(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, cx_collection: collection, service:, transaction_point: :post_service_journey, channel: Service.channels.sample) }

  before do
    disable_http_basic_auth
  end

  path '/v1/cx_collection_details' do

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

        run_test! do |response|
          data = JSON.parse(response.body)['data']
          expect(data).not_to be_empty
        end
      end
    end
  end
end
