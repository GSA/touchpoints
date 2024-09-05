# frozen_string_literal: true

require 'csv'

FactoryBot.define do
  factory :cx_collection_detail_upload do
    cx_collection_detail
    user
    job_id { rand(100_000).to_s }

    after(:create) do |cx_collection_detail_upload|
      CSV.open("spec/fixtures/sample_cx_responses_upload.csv", headers: true, encoding: "UTF-8").each do |row|
        CxResponse.create!({
          external_id: row["external_id"],
          cx_collection_detail_id: cx_collection_detail_upload.cx_collection_detail.id,
          cx_collection_detail_upload_id: cx_collection_detail_upload.id,
          job_id: cx_collection_detail_upload.job_id,
          question_1: [true, false].sample,
          positive_effectiveness: [true, false].sample,
          positive_ease: [true, false].sample,
          positive_efficiency: [true, false].sample,
          positive_transparency: [true, false].sample,
          positive_humanity: [true, false].sample,
          positive_employee: [true, false].sample,
          positive_other: [true, false].sample,
          negative_effectiveness: [true, false].sample,
          negative_ease: [true, false].sample,
          negative_efficiency: [true, false].sample,
          negative_transparency: [true, false].sample,
          negative_humanity: [true, false].sample,
          negative_employee: [true, false].sample,
          negative_other: [true, false].sample,
          question_4: "generating random text..... #{rand(999_999).to_s}",
        })
      end
    end

  end
end