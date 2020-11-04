require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load if Rails.env.development? || Rails.env.test?

module Touchpoints
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.exceptions_app = self.routes # a Rack Application

    # Initialize an array of Omniauth providers
    config.x.omniauth.providers = []

    # When I18n.config.enforce_available_locales is true we'll raise an I18n::InvalidLocale
    # exception if the passed locale is unavailable. See http://stackoverflow.com/a/20381730
    config.i18n.enforce_available_locales = false

    # The default locale is :en-US and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en-US'

    # Set list here instead of relying on backend reading translation files in case any file is incomplete
    # and we don't want to include it.
    config.i18n.available_locales = ['en-US', 'zh-CN', 'es']

    # Configure where to look for yml-based i18n files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Fallback language if translation missing in selected culture
    config.i18n.fallbacks = [I18n.default_locale]

    # Database file for country lookup by IP. From https://github.com/yhirose/maxminddb
    #config.locale_by_country_db = 'lib/GeoLite2-Country.mmdb'

    # Default locales for countries for use with IP look up
    # To add additional refer to https://en.wikipedia.org/wiki/ISO_3166-1 for codes
    config.locale_by_country = {
       # Base for supported cultures (note fr-CA missing because CA defaults to en-CA)
       'DE' => 'de-DE', # Germany
       'AU' => 'en-AU', # Australia
       'CA' => 'en-CA', # Canada
       'GB' => 'en-GB', # United Kingdon
       'IN' => 'en-IN', # India
       'SG' => 'en-SG', # Singapore
       'ID' => 'en-SG', # Indonesia
       'MY' => 'en-SG', # Malaysia
       'US' => 'en-US', # US
       'CO' => 'es-CO', # Colombia
       'MX' => 'es-MX', # Mexico
       'FR' => 'fr-FR', # France
       'JP' => 'ja-JP', # Japan
       'KR' => 'ko-KR', # Korea
       'BR' => 'pt-BR', # Brazil
       'CN' => 'zh-CN', # China
       # Additional countries
       'IE' => 'en-GB' # Ireland
    }

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    config.generators do |g|
      g.test_framework :rspec
    end

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths << Rails.root.join("lib")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # For rack-cors gem - to Support CORS requests from Touchpoints embedded on other sites
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
