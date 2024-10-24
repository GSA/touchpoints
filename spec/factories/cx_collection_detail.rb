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

  end
end