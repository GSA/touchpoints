require_relative 'vcap_services'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    namespace: "touchpoints_sidekiq_#{Rails.env}",
    ssl_params: {}
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    namespace: "touchpoints_sidekiq_#{Rails.env}",
    ssl_params: {}
  }
end
