# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load if Rails.env.development? || Rails.env.test?

module Touchpoints
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Initialize an array of Omniauth providers
    config.x.omniauth.providers = []

    # The default locale is :en-US and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en-US'

    # Set list here instead of relying on backend reading translation files in case any file is incomplete
    # and we don't want to include it.
    config.i18n.available_locales = %w[en-US zh-CN es]

    # Configure where to look for yml-based i18n files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Fallback language if translation missing in selected culture
    config.i18n.fallbacks = [I18n.default_locale]

    config.generators do |g|
      g.test_framework :rspec
    end

    config.active_job.queue_adapter = :sidekiq

    # For rack-cors gem - to Support CORS requests from Touchpoints embedded on other sites
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post options]
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
