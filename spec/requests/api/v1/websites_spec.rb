require 'swagger_helper'

RSpec.describe '/v1/websites', type: :request do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:user) { FactoryBot.create(:user, organization:, api_key: TEST_API_KEY) }
  let(:'x-api-key') { user.api_key }
  let!(:website) { FactoryBot.create(:website, organization: user.organization, aasm_state: :published) }

  before do
    disable_http_basic_auth
  end

  path '/v1/websites' do

    get('List websites') do
      description 'Returns a list of websites registered in Touchpoints.'
      tags 'Digital Registry'
      produces 'application/json'
      security [{ 'api_key': [] }]
      parameter name: 'all', in: :query, type: :integer, required: false,
                description: 'If set to 1, returns all websites. If not set or set to 0, returns only published websites.'
      
      response(200, 'successful') do
        schema type: 'object',
               required: ['data'],
               properties: {
                 data: {
                   type: 'array',
                   items: {
                     '$ref': '#/components/schemas/WebsiteResource',
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
