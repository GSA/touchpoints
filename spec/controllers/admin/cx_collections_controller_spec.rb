# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CxCollectionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organization) }
  let(:another_organization) { FactoryBot.create(:organization) }
  let(:a_third_organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization: another_organization) }
  let(:user_3) { FactoryBot.create(:user, organization: a_third_organization) }
  let(:service) { FactoryBot.create(:service, organization:, service_owner_id: user.id) }
  let(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let(:cx_collection) { FactoryBot.create(:cx_collection, organization: another_organization, service: service) }
  let(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }

  let(:valid_session) { {} }

  let(:valid_attributes) do
    FactoryBot.build(:cx_collection, organization:, user: admin, service_provider:).attributes
  end

  let(:invalid_attributes) do
    {
      name: 'Only',
      organization_id: nil,
      user_id: nil,
    }
  end

  context 'as a User' do
    before do
      sign_in(user)
    end

    describe 'GET /show' do
      it 'renders a successful response' do
        get :index, params: {}, session: valid_session
        expect(response).to be_successful
      end
    end

    context 'for a Collection from another organization' do
      describe 'GET /show' do
        let!(:cx_collection_3) { FactoryBot.create(:cx_collection, organization: user_3.organization, user: user_3, service_provider:, service:) }

        it 'renders RecordNotFound' do
          expect(user.organization_id).to_not eq(user_3.organization_id)
          expect do
            get :show, params: { id: cx_collection_3.id }, session: valid_session
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe 'GET #export_csv' do
      let!(:my_collection) { FactoryBot.create(:cx_collection, user: user, organization: user.organization, service: service) }
      let(:other_user) { FactoryBot.create(:user) }
      let(:other_service) { FactoryBot.create(:service, organization: other_user.organization, service_owner_id: other_user.id) }
      let!(:other_collection) { FactoryBot.create(:cx_collection, name: 'Other Collection', user: other_user, organization: other_user.organization, service: other_service) }

      it 'returns a success response' do
        get :export_csv, session: valid_session
        expect(response).to be_successful
        expect(response.header['Content-Type']).to include 'text/csv'
        expect(response.body).to include(my_collection.name)
      end

      it 'only includes collections for the current user' do
        get :export_csv, session: valid_session
        expect(response.body).to include(my_collection.name)
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

  context 'as admin' do
    before do
      sign_in(admin)
    end
  end
end
