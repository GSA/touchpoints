# frozen_string_literal: true

module TouchpointsSpecHelpers
  def expect_responses_fiscal_year_dropdown
    expect(page).to have_text('Export responses')
    expect(page).to have_text('Select Fiscal Year:')
    expect(page).to have_select('fiscal_year', with_options: [
      'All',
      '2025',
      '2024',
      '2023',
      '2022',
      '2021',
      '2020'
    ])
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def parse_response(body)
    JSON.parse(body.force_encoding("UTF-8"))
  end
end

RSpec.configure do |config|
  config.include TouchpointsSpecHelpers
end
