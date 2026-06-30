# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organization
    sequence(:email) { |n| "webmaster#{n}@example.gov" }
    password { 'password' }
    confirmed_at { Time.zone.now }
    trait :admin do
      email { 'admin@example.gov' }
      admin { true }
    end

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_user do
      email { 'john.smith@gsa.gov' }
      first_name { 'John' }
      last_name { 'Smith' }
      position_title { 'Service Delivery Manager' }
    end
  end
end
