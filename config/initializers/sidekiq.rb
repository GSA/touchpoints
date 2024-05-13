# frozen_string_literal: true

require_relative 'vcap_services'

redis_environments = {
  local: 0,
  development: 1,
  staging: 2,
  demo: 3,
  production: 4
}

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    size: 5,
    timeout: 60,
    ssl: (Rails.env.development? ? false : true),
    db: redis_environments[Rails.env],
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    size: 5,
    timeout: 60,
    ssl: (Rails.env.development? ? false : true),
    db: redis_environments[Rails.env],
  }
end
