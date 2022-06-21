# frozen_string_literal: true

FactoryBot.define do
  factory :digital_service_account do
    sequence(:name) { |i| "Service Account #{i}" }
  end
end
