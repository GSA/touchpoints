# frozen_string_literal: true

Rails.application.config.session_store :cookie_store, key: '_touchpoints_session', domain: ENV.fetch('TOUCHPOINTS_WEB_DOMAIN'), same_site: :lax, expire_after: 15.minutes
