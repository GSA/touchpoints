# frozen_string_literal: true

FactoryBot.define do
  factory :service_provider do
    name { 'HISP - Service Provider' }
    slug { 'dept-service' }
    organization
  end
end
