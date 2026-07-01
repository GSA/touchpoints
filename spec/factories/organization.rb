# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name) { |i| "Example.gov #{i}" }
    sequence(:domain) { |i| "example#{i}.gov" }
    sequence(:abbreviation) { |i| "EX#{i}" }
    url { 'https://example.gov' }
    notes { 'Notes about this Organization' }

    trait :parent do
      name { 'Parent.gov' }
      domain { 'parent.gov' }
      abbreviation { 'PO' }
      url { 'https://parent.gov' }
      notes { 'Notes about parent Organization' }
    end

    trait :another do
      name { 'Another.gov' }
      domain { 'another.gov' }
      abbreviation { 'AN' }
      url { 'https://another.gov' }
      notes { 'Notes about another Organization' }
    end

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_organization do
      name { 'General Service Administration' }
      domain { 'gsa.gov' }
      abbreviation { 'GSA' }
      url { 'https://www.gsa.gov/' }
      notes { '' }
    end
  end
end
