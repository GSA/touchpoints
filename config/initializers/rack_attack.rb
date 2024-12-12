class Rack::Attack
  # Throttle based on the request's IP address
  throttle('limit_form_submissions_per_minute', limit: 6, period: 1.minute) do |req|
    if req.post? && submission_route?(req)
      req.ip
    end
  end

  # Is the request to the form submission route?
  def self.submission_route?(req)
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

  # Response for throttled requests
  self.throttled_responder = lambda do |env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too many requests. Please try again later."]]
  end
end
