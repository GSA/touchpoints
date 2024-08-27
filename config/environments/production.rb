require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Enable static file serving from the `/public` folder (turn off if using NGINX/Apache for it).
  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Info include generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  Rails.application.configure do
    config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL', nil) }
  end

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "touchpoints_production"

  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.default_options = { reply_to: 'feedback-analytics@gsa.gov',
                                           return_path: 'feedback-analytics@gsa.gov' }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.active_support.escape_html_entities_in_json = false


  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false


  # For Devise
  config.action_mailer.default_url_options = { host: ENV.fetch('TOUCHPOINTS_WEB_DOMAIN'), port: 443 }

  # Prevent host header injection
  # Reference: https://github.com/ankane/secure_rails
  config.action_controller.asset_host = ENV.fetch('TOUCHPOINTS_WEB_DOMAIN')

  config.action_mailer.delivery_method = :ses
  config.action_mailer.perform_deliveries = true


  config.active_record.encryption.primary_key = ENV.fetch("RAILS_ACTIVE_RECORD_PRIMARY_KEY")
  config.active_record.encryption.deterministic_key = ENV.fetch("RAILS_ACTIVE_RECORD_DETERMINISTIC_KEY")
  config.active_record.encryption.key_derivation_salt = ENV.fetch("RAILS_ACTIVE_RECORD_KEY_DERIVATION_SALT")
  config.active_record.encryption.support_unencrypted_data = true

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    ENV.fetch("TOUCHPOINTS_WEB_DOMAIN")
  ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
