# frozen_string_literal: true
FactoryBot.define do
  factory :cx_collection_detail do
    cx_collection
    service
    service_stage_id { 2 }
    channel { 'email' }
    omb_control_number { '0345-0012' }
    survey_type { 'likert_scale' }
    survey_title { 'FY25 Customer Satisfaction Survey' }
    trust_question_text { 'Based on your experience, do you trust this agency?' }
    volume_of_customers_provided_survey_opportunity { 300 }

    trait :with_cx_collection_detail_upload do
      after(:create) do |cx_collection_detail|
        FactoryBot.create(:cx_collection_detail_upload, cx_collection_detail:)
      end
    end

  end
end