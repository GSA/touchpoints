# frozen_string_literal: true

FactoryBot.define do
  factory :service_provider do
    name { 'HISP - Service Provider' }
    slug { 'dept-service' }
    inactive { false }
    year_designated { 2024 }
    description { 'HISP is a High Impact Service Provider' }
    new { false }
    portfolio_manager_email { 'john.smith@gsa.gov' }
    notes { '' }
    department { '' }
    department_abbreviation { '' }
    bureau { '' }
    organization
  end
end
