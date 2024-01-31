# frozen_string_literal: true
FactoryBot.define do
  factory :cx_collection do
    organization
    user
    service_provider
    service
    service_type {}
    name { 'Test Data Collection' }
    start_date { '2023-10-01' }
    end_date { '2023-12-31' }
    fiscal_year { '2024' }
    quarter { '1' }
    reflection { 'What this data meant for our operations' }
  end
end