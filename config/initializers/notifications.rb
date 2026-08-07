ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
  Rails.logger.info("[Rack::Attack] #{payload[:request].ip} blocked for #{payload[:discriminator]}")
end
