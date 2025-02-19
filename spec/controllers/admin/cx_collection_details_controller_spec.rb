# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CxCollectionDetailsController, type: :controller do
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
  end

  context 'as admin' do
    before do
      sign_in(admin)
    end

    describe 'GET #export_csv' do
    let!(:cx_collection_detail2) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }

      it 'renders a successful response' do
        get :export_csv, params: { id: cx_collection_detail.cx_collection_id }, session: valid_session
        expect(response).to be_successful

        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq(
          [
            "id",
            "organization_id",
            "organization_abbreviation",
            "organization_name",
            "cx_collection_id",
            "cx_collection_fiscal_year",
            "cx_collection_quarter",
            "cx_collection_name",
            "cx_collection_service_provider_id",
            "cx_collection_service_provider_name",
            "cx_collection_service_provider_slug",
            "service_id",
            "service_name",
            "transaction_point",
            "channel",
            "service_stage_id",
            "service_stage_name",
            "service_stage_position",
            "service_stage_count",
            "volume_of_customers",
            "volume_of_customers_provided_survey_opportunity",
            "volume_of_respondents",
            "omb_control_number",
            "survey_type",
            "survey_title",
            "trust_question_text",
            "created_at",
            "updated_at",
          ]
        )
        expect(csv.size).to eq(2)
      end
    end

    let(:user) { create(:user) }
    let(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }
    let(:valid_csv) do
      <<~CSV
        external_id,question_1,positive_effectiveness,positive_ease,positive_efficiency,positive_transparency,positive_humanity,positive_employee,positive_other,negative_effectiveness,negative_ease,negative_efficiency,negative_transparency,negative_humanity,negative_employee,negative_other,question_4
        123,Yes,1,1,1,1,1,1,1,0,0,0,0,0,0,0,No
      CSV
    end

    let(:invalid_headers_csv) do
      <<~CSV
        wrong_header_1,wrong_header_2
        value1,value2
      CSV
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:s3_bucket).and_return(double('S3Bucket', object: double('S3Object', upload_file: true, size: 1000, key: 's3-key')))
    end

    describe 'POST #upload_csv' do
      context 'with a valid CSV file' do
        it 'uploads successfully and creates a CxCollectionDetailUpload' do
          file = File.open("spec/fixtures/sample_cx_responses_upload.csv")
          post :upload_csv, params: { file: Rack::Test::UploadedFile.new(file.path, 'text/csv'), id: cx_collection_detail.id }
          expect(response).to redirect_to(upload_admin_cx_collection_detail_path(cx_collection_detail))
          expect(flash[:notice]).to match(/A .csv file with \d+ rows was uploaded successfully/)
        end
      end

      context 'with a valid CSV BOM byte order marked file' do
        it 'uploads successfully and creates a CxCollectionDetailUpload ' do
          file = File.open("spec/fixtures/sample_cx_responses_upload_with_bom.csv")
          post :upload_csv, params: { file: Rack::Test::UploadedFile.new(file.path, 'text/csv'), id: cx_collection_detail.id }
          expect(response).to redirect_to(upload_admin_cx_collection_detail_path(cx_collection_detail))
          expect(flash[:notice]).to match(/A .csv file with \d+ rows was uploaded successfully/)
        end
      end

      context 'with an invalid file extension' do
        it 'shows an alert message' do
          file = Tempfile.new(['invalid', '.txt'])
          file.write(valid_csv)
          file.rewind

          post :upload_csv, params: { file: Rack::Test::UploadedFile.new(file.path, 'text/plain'), id: cx_collection_detail.id }

          expect(response).to redirect_to(upload_admin_cx_collection_detail_path(cx_collection_detail))
          expect(flash[:notice]).to match(/File has a file extension of .txt, but it should be .csv./)
        ensure
          file.close
          file.unlink
        end
      end

      context 'with invalid CSV headers' do
        it 'shows a header mismatch error' do
          file = Tempfile.new(['invalid_headers', '.csv'])
          file.write(invalid_headers_csv)
          file.rewind

          post :upload_csv, params: { file: Rack::Test::UploadedFile.new(file.path, 'text/csv'), id: cx_collection_detail.id }

          expect(response).to redirect_to(upload_admin_cx_collection_detail_path(cx_collection_detail))
          expect(flash[:alert]).to match(/CSV headers do not match/)
        ensure
          file.close
          file.unlink
        end
      end
    end

  end
end
