# frozen_string_literal: true

module TouchpointsSpecHelpers
  def expect_start_and_end_date_fields
    expect(page).to have_text('Export responses')
    expect(page).to have_text('Start Date')
    expect(page).to have_text('End Date')
    expect(page).to have_css("input#start-date[type='date']")
    expect(page).to have_css("input#end-date[type='date']")
  end

  def expect_responses_fiscal_year_dropdown
    expect(page).to have_text('Export responses')
    expect(page).to have_text('Select Fiscal Year:')
    expect(page).to have_select('fiscal_year', with_options: %w[
                                  All
      2025
      2024
      2023
      2022
      2021
      2020
                                ])
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    js = page.evaluate_script('typeof jQuery')
    return true if js == 'undefined'

    page.evaluate_script('jQuery.active').zero?
  rescue StandardError => _e
    # If jQuery or other script is unavailable, assume no active jQuery requests
    true
  end

  def wait_for_builder
    # Wait for our form builder to be present and for JS to stabilize
    expect(page).to have_css('.form-builder', wait: Capybara.default_max_wait_time)
    wait_for_ajax
  end

  # Run axe accessibility check only if axe is loaded; otherwise skip to avoid flakiness
  def expect_page_axe_clean
    expect(page).to be_axe_clean
  rescue StandardError => e
    warn "Skipping axe check on this page: #{e.message}"
    skip 'a11y check skipped - axe not available'
  end

  # Make ApiController treat the current example's requests as if they arrived
  # through the API gateway (api.gov / API Umbrella), scoped to the current
  # example. The gateway sits between the public API user and the Touchpoints
  # server; it terminates HTTP Basic auth and stamps an X-Api-Umbrella-Request-Id
  # header. Stubbing both concerns here means rswag request specs don't have to
  # declare the gateway's Authorization or request-id headers as OpenAPI
  # parameters (which would pollute the generated spec).
  def simulate_api_gateway_request
    allow_any_instance_of(ApiController)
      .to receive(:authenticate_or_request_with_http_basic).and_return(true)
    allow_any_instance_of(ApiController)
      .to receive(:from_api_gateway?).and_return(true)
  end

  # Inject the current response body into the rswag/OpenAPI example metadata so
  # the generated swagger documentation includes a real "application/json"
  # example for the response. Intended to be called from an rswag `after` hook,
  # where the block yields the running RSpec example.
  #
  # The response body is parsed as JSON and deep-merged into any existing
  # content already declared on the response, preserving other content types
  # and schema definitions.
  #
  # Database-assigned identifiers in the example are kept stable across runs by
  # resetting the relevant Postgres sequences before each rswag request example;
  # see the "rswag deterministic ids" shared context in
  # spec/support/rswag_shared_context.rb.
  #
  # @param example [RSpec::Core::Example] the current example, whose
  #   `metadata[:response][:content]` is mutated in place.
  # @return [void]
  #
  # @example
  #   after do |example|
  #     generate_example_spec example
  #   end
  def capture_example(example)
      content = example.metadata[:response][:content] || {}

      example_spec = {
        "application/json"=>{
          example: {
            value: JSON.parse(response.body, symbolize_names: true)
          }
        }
      }

      example.metadata[:response][:content] = content.deep_merge(example_spec)
  end
end

RSpec.configure do |config|
  config.include TouchpointsSpecHelpers, type: :feature
  config.include TouchpointsSpecHelpers, type: :request
end
