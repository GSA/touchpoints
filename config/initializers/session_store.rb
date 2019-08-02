Rails.application.config.session_store :cookie_store, key: '_touchpoints_session', same_site: :strict, expire_after: 15.minutes
