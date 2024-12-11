class Rack::Attack
  throttle('limit_form_submissions', limit: 6, period: 1.minute) do |req|
    if req.post? && route_matches?(req, :submit_form)
      req.ip # Throttle based on the request's IP address
    end
  end

  # Helper method to check if the route matches the named route
  def self.route_matches?(req, named_route)
    begin
      recognized_route = Rails.application.routes.recognize_path(req.path, method: req.request_method)
      recognized_route[:controller] == 'forms' && recognized_route[:action] == 'submit'
    rescue ActionController::RoutingError
      false
    end
  end

  # Custom response for throttled requests
  self.throttled_response = lambda do |env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests. Please try again later."]]
  end
end
