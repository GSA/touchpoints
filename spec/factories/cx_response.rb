# frozen_string_literal: true
FactoryBot.define do
  factory :cx_response do
    cx_collection_detail
    cx_collection_detail_upload
    external_id { rand(100_000).to_s }
  end
end
