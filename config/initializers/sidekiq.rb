# frozen_string_literal: true

require_relative 'vcap_services'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    namespace: "touchpoints_sidekiq_#{Rails.env}",
    ssl_params: {},
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    namespace: "touchpoints_sidekiq_#{Rails.env}",
    ssl_params: {},
  }
end
