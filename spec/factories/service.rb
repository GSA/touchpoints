# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    name { 'Service to deliver to customer' }
    service_slug { 'dept-service' }
    organization
    service_provider

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_service do
      name { 'Navigating information and tasks during critical life experiences' }
      description { 'Many users interact with government when they are experiencing a significant life event – such as the birth of a child, marriage or divorce, financial hardship or the loss of a loved one – and frequently, these experiences lead them across Federal agencies in a disconnected journey of discrete tasks. Because USAGov already provides content on common tasks and are not affiliated with any particular agency, USAGov is ideally positioned as a navigational aid for these users.' }
      short_description { '' }
      previously_reported { false }
      contact_center { true }
      kind { ['Informational'] }
      transactional { false }
      notes { '' }
      hisp { true }
      service_slug { 'gsa-usagov' }
      homepage_url { 'https://www.usa.gov/' }
      url { 'https://www.usa.gov/life-events' }
      fully_digital_service { true }
      aasm_state { 'verified' }
    end
  end
end
