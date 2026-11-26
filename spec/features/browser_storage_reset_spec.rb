# frozen_string_literal: true

require 'rails_helper'

# Regression coverage for the Capybara Chrome cleanup monkey patch in
# spec/support/chrome_storage_reset.rb: cookies and storage must not leak between tests.
# Can be removed with the patch once a released Capybara fix for PR #2868 is
# installed and browser-reset cleanup is verified on the CI Chrome version.
feature 'Browser session isolation', js: true do
  scenario 'reset clears cookies and local storage between browser sessions' do
    visit index_path
    page.driver.browser.manage.add_cookie(name: 'reset_probe', value: 'synthetic-test-value', path: '/')
    page.execute_script("localStorage.setItem('reset_probe', 'synthetic-test-value')")

    expect(page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }).to include('reset_probe')
    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to eq('synthetic-test-value')

    # Exercise the same cleanup used by Capybara's RSpec after hook.
    Capybara.reset_sessions!
    visit index_path

    aggregate_failures do
      expect(page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }).not_to include('reset_probe')
      expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to be_nil
    end
  end

  scenario 'reset handles an open alert and still clears browser storage' do
    visit index_path
    page.driver.browser.manage.add_cookie(name: 'reset_probe', value: 'synthetic-test-value', path: '/')
    page.execute_script("localStorage.setItem('reset_probe', 'synthetic-test-value')")
    page.execute_script("setTimeout(() => alert('Browser reset regression probe'), 0)")

    # Observe the alert without accepting it, leaving reset to handle it.
    Selenium::WebDriver::Wait.new(timeout: Capybara.default_max_wait_time).until do
      page.driver.browser.switch_to.alert.text == 'Browser reset regression probe'
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      false
    end

    Capybara.reset_sessions!
    visit index_path

    aggregate_failures do
      expect(page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }).not_to include('reset_probe')
      expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to be_nil
    end
  end
end
