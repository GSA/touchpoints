# frozen_string_literal: true

cookie_domain = ENV['SESSION_COOKIE_DOMAIN'].presence
Rails.application.config.session_store :cookie_store,
  key: '_touchpoints_session',
  domain: cookie_domain,
  same_site: :lax,
  expire_after: 30.minutes
