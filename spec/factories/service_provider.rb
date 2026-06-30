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

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_service_provider do
      name { 'Public Experience Portfolio' }
      slug { 'gsa-usagov' }
      inactive { false }
      year_designated { 2022 }
      description { 'The Public Experience Portfolio strives to unify, improve, and standardize the experience the public has interacting with the Federal government. The Public Experience Portfolio operates USAGov, a program that connects people with government information more than 113 million times a year through websites (USA.gov and USAGov en español), social media, email, and phone calls and chats to the USAGov Contact Center.' }
      new { false }
      portfolio_manager_email { 'jane.smith@gsa.gov' }
      notes { '' }
      department { 'gsa' }
      department_abbreviation { 'gsa' }
      bureau { 'Public Experience Portfolio' }
    end
  end
end
