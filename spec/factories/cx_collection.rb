# frozen_string_literal: true
FactoryBot.define do
  factory :cx_collection do
    organization
    user
    service_provider
    service
    service_type {}
    name { 'Test Data Collection' }
    fiscal_year { '2024' }
    quarter { '1' }
  end
end