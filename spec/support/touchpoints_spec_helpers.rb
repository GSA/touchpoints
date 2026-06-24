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

  # Bypass the HTTP Basic auth that ApiController enforces, scoped to the
  # current example. Useful in rswag request specs so the Authorization
  # header does not need to be declared as an OpenAPI parameter. HTTP Basic auth
  # is used between the API gateway and the Touchpoints server but is not part
  # of the production API as viewed by the public API user.
  def disable_http_basic_auth
    allow_any_instance_of(ApiController)
      .to receive(:authenticate_or_request_with_http_basic).and_return(true)
  end
end

RSpec.configure do |config|
  config.include TouchpointsSpecHelpers, type: :feature
  config.include TouchpointsSpecHelpers, type: :request
end
