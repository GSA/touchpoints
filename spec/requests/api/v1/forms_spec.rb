# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe '/v1/forms', type: :request do
  include_context 'rswag deterministic examples'

  let!(:organization) { FactoryBot.create(:documented_organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:form) { FactoryBot.create(:documented_form, organization:) }
  let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user:, form:) }

  before do
    simulate_api_gateway_request
  end

  path '/forms' do
    get('List forms') do
      description 'Returns a list of forms accessible to the user with the given API key. Does not include form responses.'
      tags 'Forms'
      produces 'application/json'
      security [{ api_key: [] }]

      response(200, 'successful') do
        schema type: 'object',
               required: %w[data],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/FormResource',
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

  path '/forms/{uuid}' do
    parameter name: 'uuid', in: :path, type: :string, description: 'Short UUID of the form'

    get('Show form') do
      description 'Returns details for the given form. Form must be accessible to the calling user.

**Submissions field is deprecated:** This has traditionally been the endpoint used to retrieve a form\'s responses, returned as
paginated results in the `submissions` field. However, the pagination has known issues that proved difficult to fix in a backward-compatible manner.
As a result, we’ve introduced a new /v1/forms/{uuid}/responses endpoint, which should be used to retrieve survey responses going forward.
'
      tags 'Forms'
      produces 'application/json'
      security [{ api_key: [] }]
      parameter name: 'page', in: :query, type: :integer, required: false,
                description: 'Page number, 1-based (default: 1)', deprecated: true
      parameter name: 'size', in: :query, type: :integer, required: false,
                description: 'Responses per page (default: 500, max: 5000)', deprecated: true
      parameter name: :start_date, in: :query, type: :string, required: false,
                description: 'Include responses on or after this date, YYYY-MM-DD (default: 1 year ago)', deprecated: true
      parameter name: :end_date, in: :query, type: :string, required: false,
                description: 'Include responses on or before this date, YYYY-MM-DD (default: tomorrow)', deprecated: true

      response(200, 'successful') do
        schema type: 'object',
               required: %w[data links],
               properties: {
                 data: {
                   '$ref': '#/components/schemas/FormResource',
                 },
                 included: {
                   deprecated: true,
                   type: 'array',
                   description: 'Sideloaded submission records for the current page.',
                   items: {
                     '$ref': '#/components/schemas/SubmissionResource',
                   },
                 },
                 links: {
                   deprecated: true,
                   '$ref': '#/components/schemas/DeprecatedPaginationLinks',
                 },
               }

        let(:uuid) { form.short_uuid }

        run_test!
      end
    end
  end

  path '/forms/{uuid}/responses' do
    parameter name: 'uuid', in: :path, type: :string, description: 'Short UUID of the form'

    get('List responses for form') do
      description 'Returns a paginated list of responses submitted for the given form. Form must be accessible to the calling user.'
      tags 'Forms'
      produces 'application/json'
      security [{ api_key: [] }]
      parameter name: 'page[number]', in: :query, type: :integer, required: false,
                description: 'Page number, 1-based (default: 1)'
      parameter name: 'page[size]', in: :query, type: :integer, required: false,
                description: 'Responses per page (default: 500, max: 5000)'
      parameter name: :start_date, in: :query, type: :string, required: false,
                description: 'Include responses on or after this date, YYYY-MM-DD (default: No lower-bound limit)'
      parameter name: :end_date, in: :query, type: :string, required: false,
                description: 'Include responses on or before this date, YYYY-MM-DD (default: No upper-bound limit)'

      response(200, 'successful') do
        schema type: 'object',
               required: %w[data links meta],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/SubmissionResource',
                   },
                 },
                 links: {
                   '$ref': '#/components/schemas/PaginationLinks',
                 },
                 meta: {
                   '$ref': '#/components/schemas/PaginationMeta',
                 },
               }

        let(:uuid) { form.short_uuid }
        let(:'page[size]') { 2 }
        let(:start_date) { '2023-01-01' }

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
