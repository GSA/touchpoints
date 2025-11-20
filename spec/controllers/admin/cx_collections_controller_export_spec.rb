# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CxCollectionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:service) { FactoryBot.create(:service, organization: organization, service_owner_id: user.id) }
  let(:service_provider) { FactoryBot.create(:service_provider, organization: organization) }
  let!(:cx_collection) { FactoryBot.create(:cx_collection, organization: organization, service: service, user: user, service_provider: service_provider) }

  let(:valid_session) { {} }

  context 'as a User' do
    before do
      sign_in(user)
    end

    describe 'GET #export_csv' do
      let(:other_user) { FactoryBot.create(:user) }
      let(:other_service) { FactoryBot.create(:service, organization: other_user.organization, service_owner_id: other_user.id) }
      let!(:other_collection) { FactoryBot.create(:cx_collection, name: 'Other Collection', user: other_user, organization: other_user.organization, service: other_service) }

      it 'returns a success response' do
        get :export_csv, session: valid_session
        expect(response).to be_successful
        expect(response.header['Content-Type']).to include 'text/csv'
        expect(response.body).to include(cx_collection.name)
      end

      it 'only includes collections for the current user' do
        get :export_csv, session: valid_session
        expect(response.body).to include(cx_collection.name)
        expect(response.body).not_to include(other_collection.name)
      end

      it 'handles nil associations gracefully' do
        # Create a collection with missing associations to test safe navigation
        collection_with_issues = FactoryBot.build(:cx_collection, organization: organization, user: user)
        collection_with_issues.save(validate: false)
        # Manually set associations to nil if FactoryBot enforces them
        collection_with_issues.update_columns(service_id: nil, service_provider_id: nil)

        get :export_csv, session: valid_session
        expect(response).to be_successful
        expect(response.body).to include(collection_with_issues.name)
      end
    end
  end
end
