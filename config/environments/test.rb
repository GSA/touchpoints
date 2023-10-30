# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!
require 'active_record'
require 'bullet'

Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.raise         = false # raise an error if n+1 query occurs
  end

  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}",
  }

  config.action_mailer.perform_deliveries = false
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.active_job.queue_adapter = :test

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.active_support.escape_html_entities_in_json = false

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # For Devise
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.active_record.encryption.primary_key = ENV.fetch("RAILS_ACTIVE_RECORD_PRIMARY_KEY")
  config.active_record.encryption.deterministic_key = ENV.fetch("RAILS_ACTIVE_RECORD_DETERMINISTIC_KEY")
  config.active_record.encryption.key_derivation_salt = ENV.fetch("RAILS_ACTIVE_RECORD_KEY_DERIVATION_SALT")
  config.active_record.encryption.support_unencrypted_data = true
end
