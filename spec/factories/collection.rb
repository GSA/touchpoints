# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    organization
    user
    service_provider
    name { 'Test Data Collection' }
    start_date { '2021-03-01' }
    end_date { '2021-06-30' }
    year { '2021' }
    quarter { '2' }
    reflection { 'What this data meant for our operations' }
  end
end
