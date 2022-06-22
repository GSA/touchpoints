# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    name { 'Service to deliver to customer' }
    service_slug { 'dept-service' }
    organization
  end
end
