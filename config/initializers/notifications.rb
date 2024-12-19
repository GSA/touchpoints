ActiveSupport::Notifications.subscribe("spam_subverted") do |name, start, finish, request_id, payload|
  Rails.logger.warn("SPAM subverted from #{payload[:request].referer}, IP: #{payload[:request].remote_ip}, User-Agent: #{payload[:request].user_agent}")
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
  Rails.logger.info("[Rack::Attack] #{payload[:request].ip} blocked for #{payload[:discriminator]}")
end
