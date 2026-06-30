# frozen_string_literal: true
FactoryBot.define do
  factory :cx_collection_detail do
    cx_collection
    service

    trait :with_cx_collection_detail_upload do
      after(:create) do |cx_collection_detail|
        FactoryBot.create(:cx_collection_detail_upload, cx_collection_detail:)
      end
    end

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_cx_collection_detail do
      service_stage_id { 2 }
      channel { 'email' }
      omb_control_number { '0345-0012' }
      survey_type { 'likert_scale' }
      survey_title { 'FY25 Customer Satisfaction Survey' }
      trust_question_text { 'Based on your experience, do you trust this agency?' }
      volume_of_customers_provided_survey_opportunity { 300 }
      transaction_point { :post_service_journey }

      after(:create) do |cx_collection_detail|
        FactoryBot.create(:documented_cx_collection_detail_upload, cx_collection_detail:)
      end
    end
  end
end