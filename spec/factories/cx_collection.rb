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

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_cx_collection do
      name { 'CX Quarterly Reporting' }
      fiscal_year { '2024' }
      quarter { '2' }
      aasm_state { :published }
      rating { 'TRUE' }
    end
  end
end