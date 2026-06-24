# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    name { 'Service to deliver to customer' }
    service_slug { 'dept-service' }
    short_description { 'Provides help for the confused' }
    description { 'Provides help for the confused' }
    notes { 'Poorly funded' }
    homepage_url { 'http://example.com' }
    kind { ['Benefits'] }
    organization
  end
end
