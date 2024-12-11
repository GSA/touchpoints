class Rack::Attack
  throttle('limit_form_submissions_per_minute', limit: 6, period: 1.minute) do |req|
    if req.post? && (route_matches?(req, :touchpoint_submissions) || route_matches?(req, :form_submissions))
      req.ip # Throttle based on the request's IP address
    end
  end

  # Check if the route matches the named route
  def self.route_matches?(req, named_route)
    begin
      recognized_route = Rails.application.routes.recognize_path(req.path, method: req.request_method)
      recognized_route[:controller] == 'submissions' &&
        recognized_route[:action] == 'create' &&
        recognized_route[:touchpoint_id].present? &&
        recognized_route[:format] == 'json'
    rescue ActionController::RoutingError
      false
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests. Please try again later."]]
  end
end
