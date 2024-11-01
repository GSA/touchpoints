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
  end

  context 'as admin' do
    before do
      sign_in(admin)
    end

    describe 'GET csv' do
      it 'renders a successful response' do
        get :export_cx_responses_csv, params: { id: cx_collection_detail.cx_collection_id }, session: valid_session
        expect(response).to be_successful

        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq(
          [
            "cx_collection_detail_id",
            "cx_collection_detail_upload_id",
            "question_1",
            "positive_effectiveness",
            "positive_ease",
            "positive_efficiency",
            "positive_transparency",
            "positive_humanity",
            "positive_employee",
            "positive_other",
            "negative_effectiveness",
            "negative_ease",
            "negative_efficiency",
            "negative_transparency",
            "negative_humanity",
            "negative_employee",
            "negative_other",
            "question_4",
            "job_id",
            "external_id"]
        )

        expect(csv.size).to eq(1000)
      end
    end
  end
end
