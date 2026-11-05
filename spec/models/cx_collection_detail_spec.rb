require 'rails_helper'

RSpec.describe CxCollectionDetail, type: :model do

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization: user.organization, service_provider: service_provider, service_owner_id: user.id) }

  let!(:cx_collection) { FactoryBot.create(:cx_collection, organization:, service:, service_provider: service_provider, quarter: 2, fiscal_year: 2024, aasm_state: :published) }
  let!(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }

  let!(:cx_collection2) { FactoryBot.create(:cx_collection, organization:, service:, service_provider: service_provider, quarter: 2, fiscal_year: 2024, aasm_state: :published) }
  let!(:cx_collection_detail2) { FactoryBot.create(:cx_collection_detail, :with_cx_collection_detail_upload, cx_collection: cx_collection2, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }

  describe 'cx_collection with respones' do
    context '#to_csv' do
      let!(:csv) { CSV.parse(CxCollectionDetail.to_csv, headers: true) }

      it 'specifies headers' do
        expect(csv.headers).to eq([
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
          "updated_at"
        ])
      end

      it 'expects volume to be 1,000 each (and not the sum of all responses: regression)' do
        expect(csv.class).to eq(CSV::Table)
        expect(csv.size).to eq(2)

        expect(csv[0].to_s).to include(",3,,,1000")
        expect(csv[-1].to_s).to include(",3,,,1000")

        expect(csv[0].to_s).to_not include("2000")
      end
    end
  end

  describe '#form_id_int' do
    it 'is set from a numeric form_id on create' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: "123")

      expect(detail.form_id_int).to eq(123)
    end

    it 'strips surrounding whitespace before converting to an integer' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: "  456  ")

      expect(detail.form_id_int).to eq(456)
    end

    it 'is nil when form_id is non-numeric' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: "abc123")

      expect(detail.form_id_int).to be_nil
    end

    it 'is nil when form_id is blank' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: nil)

      expect(detail.form_id_int).to be_nil
    end

    it 'stays in sync when form_id is changed on an existing record' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: "123")
      expect(detail.form_id_int).to eq(123)

      detail.update!(form_id: "789")

      expect(detail.form_id_int).to eq(789)
    end

    it 'clears form_id_int when form_id is updated to a non-numeric value' do
      detail = FactoryBot.create(:cx_collection_detail, cx_collection:, service:, transaction_point: :post_service_journey, channel: Service.channels.sample, form_id: "123")
      expect(detail.form_id_int).to eq(123)

      detail.update!(form_id: "not-a-number")

      expect(detail.form_id_int).to be_nil
    end
  end
end
