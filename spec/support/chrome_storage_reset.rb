# frozen_string_literal: true

require 'uri'
require 'capybara/selenium/driver'

# Temporary compatibility fix for Capybara 3.40.0 and Chrome 158+.
# Monkey-patches Capybara's Chrome driver to handle rejected wildcard-origin cleanup.
# Upstream tracking: https://github.com/teamcapybara/capybara/pull/2868
# Revisit when Capybara releases the fix. Never suppress a failed cleanup.
module ChromeStorageReset
  def visit(path)
    super
    remember_storage_origin(current_url)
  end

  def reset!
    return super unless @browser

    # Capture redirected pages and extra windows before Capybara closes them
    # and navigates to about:blank. Also retain origins from earlier visits.
    original_window = current_window_handle
    window_handles.each do |handle|
      switch_to_window(handle)
      remember_storage_origin(current_url)
    end
    switch_to_window(original_window)

    super
    @storage_reset_origins = []
  end

  private

  def remember_storage_origin(url)
    uri = URI.parse(url)
    return unless %w[http https].include?(uri.scheme) && uri.host

    origin = "#{uri.scheme}://#{uri.hostname.include?(':') ? "[#{uri.hostname}]" : uri.hostname}:#{uri.port}"
    @storage_reset_origins ||= []
    @storage_reset_origins |= [origin]
  end

  def execute_cdp(command, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => error
    raise unless command == 'Storage.clearDataForOrigin' && params[:origin] == '*' &&
                 error.message.include?('* is not a valid URL')

    # Chrome 158 rejects wildcard origins; cookie clearing remains global.
    super('Network.clearBrowserCookies', {})
    storage_types = params.fetch(:storageTypes).split(',') - ['cookies']
    return if storage_types.empty?

    Array(@storage_reset_origins).each do |origin|
      super(command, { origin: origin, storageTypes: storage_types.join(',') })
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
