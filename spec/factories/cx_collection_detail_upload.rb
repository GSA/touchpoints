# frozen_string_literal: true

require 'csv'

FactoryBot.define do
  factory :cx_collection_detail_upload do
    cx_collection_detail
    user
    job_id { rand(100_000).to_s }

    after(:create) do |cx_collection_detail_upload|
      CSV.open('spec/fixtures/sample_cx_responses_upload.csv', headers: true).each do |row|
        CxResponse.create!({
          external_id: row['external_id'],
          cx_collection_detail_id: cx_collection_detail_upload.cx_collection_detail.id,
          cx_collection_detail_upload_id: cx_collection_detail_upload.id,
          job_id: cx_collection_detail_upload.job_id,
          question_1: ['1', '0'].sample,
          positive_effectiveness: ['1', '0'].sample,
          positive_ease: ['1', '0'].sample,
          positive_efficiency: ['1', '0'].sample,
          positive_transparency: ['1', '0'].sample,
          positive_humanity: ['1', '0'].sample,
          positive_employee: ['1', '0'].sample,
          positive_other: ['1', '0'].sample,
          negative_effectiveness: ['1', '0'].sample,
          negative_ease: ['1', '0'].sample,
          negative_efficiency: ['1', '0'].sample,
          negative_transparency: ['1', '0'].sample,
          negative_humanity: ['1', '0'].sample,
          negative_employee: ['1', '0'].sample,
          negative_other: ['1', '0'].sample,
          question_4: "generating random text..... #{rand(999_999).to_s}",
        })
      end
    end

  end
end