# frozen_string_literal: true

FactoryBot.define do
  factory :website do
    sequence(:domain) { |n| "subdomain#{n}.example.gov" }
    type_of_site { 'application' }
    office { 'OFFICE' }
    sub_office { 'SUBOFFICE' }

    # Curated, deterministic values for use as OpenAPI documentation examples
    # (see TouchpointsSpecHelpers#capture_example). Unlike the default factory
    # values, these are chosen to read well in published API docs and must not
    # use random data, so the generated openapi.yml stays stable across runs.
    factory :documented_website do
      domain { 'touchpoints.app.cloud.gov' }
      office { 'FAS' }
      sub_office { 'TTS' }
      contact_email { 'feedback-analytics@gsa.gov' }
      site_owner_email { 'john.smith@gsa.gov' }
      production_status { 'production' }
      type_of_site { 'Application' }
      required_by_law_or_policy { 'A-11, Section 280' }
      has_dap { false }
      uses_feedback { true }
      feedback_tool { 'Touchpoints' }
      backlog_tool { 'GitHub' }
      backlog_url { '' }
      has_search { false }
      has_authenticated_experience { true }
      authentication_tool { 'Login.gov' }
      repository_url { 'https://github.com/gsa/touchpoints' }
      hosting_platform { 'cloud.gov' }
      https { true }
      uswds_version { '3.1' }
    end
  end
end
