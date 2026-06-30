require 'swagger_helper'

RSpec.describe '/v1/cx_responses', type: :request do
  include_context 'rswag deterministic examples'

  let!(:organization) { FactoryBot.create(:documented_organization) }
  let!(:user) { FactoryBot.create(:user, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:service_provider) { FactoryBot.create(:documented_service_provider, organization:) }
  let!(:service) { FactoryBot.create(:documented_service, organization:, service_provider:, service_owner_id: user.id) }
  let!(:cx_collection) { FactoryBot.create(:documented_cx_collection, organization:, user:, service_provider:, service:) }
  let!(:cx_collection_detail) { FactoryBot.create(:documented_cx_collection_detail, cx_collection:, service:) }

  before do
    simulate_api_gateway_request
  end

  path '/cx_responses' do

    get('List CX responses') do
      description 'Returns a paginated list of CX responses for all CX collection details'
      tags 'CX Collections'
      produces 'application/json'
      security [{ 'api_key': [] }]
      parameter name: 'page[number]', in: :query, type: :integer, required: false,
                description: 'Page number, 1-based (default: 1)'
      parameter name: 'page[size]', in: :query, type: :integer, required: false,
                description: 'Responses per page (default: 500, max: 5000)'
      parameter name: :start_date, in: :query, type: :string, required: false,
                description: 'Include responses on or after this date, YYYY-MM-DD (default: 2024-10-01)'
      parameter name: :end_date, in: :query, type: :string, required: false,
                description: 'Include responses on or before this date, YYYY-MM-DD (default: tomorrow)'
      
      response(200, 'successful') do
        schema type: 'object',
               required: %w[data links meta],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/CxResponseResource',
                   },
                 },
                 links: {
                   '$ref': '#/components/schemas/PaginationLinks',
                 },
                 meta: {
                   '$ref': '#/components/schemas/PaginationMeta',
                 },
               }

        let(:'page[size]') { 2 }
        let(:end_date) { '2026-01-01' }

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
