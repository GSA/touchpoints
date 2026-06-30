# frozen_string_literal: true

require 'csv'

FactoryBot.define do
  factory :cx_collection_detail_upload do
    cx_collection_detail
    user
    job_id { rand(100_000).to_s }

    trait :with_random_responses do
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

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_cx_collection_detail_upload do
      job_id { '3889' }


      after(:create) do |cx_collection_detail_upload|
        CxResponse.create!({
                             external_id: '5983548',
                             cx_collection_detail_id: cx_collection_detail_upload.cx_collection_detail.id,
                             cx_collection_detail_upload_id: cx_collection_detail_upload.id,
                             job_id: cx_collection_detail_upload.job_id,
                             question_1: '1',
                             positive_effectiveness: '0',
                             positive_ease: '1',
                             positive_efficiency: '0',
                             positive_transparency: 'null',
                             positive_humanity: 'null',
                             positive_employee: 'null',
                             positive_other: '0',
                             negative_effectiveness: '0',
                             negative_ease: '0',
                             negative_efficiency: '0',
                             negative_transparency: 'null',
                             negative_humanity: 'null',
                             negative_employee: 'null',
                             negative_other: '0',
                             question_4: 'USA.gov provides free yearly credit reports!',
                             created_at: '2024-10-07T14:47:14.260Z',
                             updated_at: '2024-10-07T14:47:14.260Z',
                           })

        CxResponse.create!({
                             external_id: '59BzdLf549wnw5P',
                             cx_collection_detail_id: cx_collection_detail_upload.cx_collection_detail.id,
                             cx_collection_detail_upload_id: cx_collection_detail_upload.id,
                             job_id: cx_collection_detail_upload.job_id,
                             question_1: '0',
                             positive_effectiveness: '0',
                             positive_ease: '0',
                             positive_efficiency: '0',
                             positive_transparency: 'null',
                             positive_humanity: 'null',
                             positive_employee: 'null',
                             positive_other: '0',
                             negative_effectiveness: '0',
                             negative_ease: '0',
                             negative_efficiency: '0',
                             negative_transparency: 'null',
                             negative_humanity: 'null',
                             negative_employee: 'null',
                             negative_other: '1',
                             question_4: 'Not sure, I only used the passport application',
                             created_at: '2024-10-19T14:47:14.260Z',
                             updated_at: '2024-10-19T14:47:14.260Z',
                           })
        CxResponse.create!({
                             external_id: 'aJoC9FWhzj',
                             cx_collection_detail_id: cx_collection_detail_upload.cx_collection_detail.id,
                             cx_collection_detail_upload_id: cx_collection_detail_upload.id,
                             job_id: cx_collection_detail_upload.job_id,
                             question_1: '1',
                             positive_effectiveness: '0',
                             positive_ease: '0',
                             positive_efficiency: '1',
                             positive_transparency: 'null',
                             positive_humanity: 'null',
                             positive_employee: 'null',
                             positive_other: '0',
                             negative_effectiveness: '0',
                             negative_ease: '0',
                             negative_efficiency: '0',
                             negative_transparency: 'null',
                             negative_humanity: 'null',
                             negative_employee: 'null',
                             negative_other: '0',
                             question_4: 'First time visiting USA.Gov so I don\'t have much feedback.',
                             created_at: '2025-01-02T14:47:14.260Z',
                             updated_at: '2025-01-02T14:47:14.260Z',
                           })
      end
    end
  end
end
