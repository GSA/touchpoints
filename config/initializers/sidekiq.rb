Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_CACHE_STORE"], namespace: "touchpoints_sidekiq_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_CACHE_STORE"], namespace: "touchpoints_sidekiq_#{Rails.env}" }
end