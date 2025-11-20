class Rack::Attack
  if Rails.env.test?
    cache.store = ActiveSupport::Cache::MemoryStore.new
  elsif ENV.fetch('REDIS_URL', nil) # can be used when multiple app instances are running
    cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL'))
  else # default; caches on a per-application instance basis
    cache.store = Rails.cache
  end

  # Throttle based on the request's IP address
  throttle('limit_form_submissions_per_minute', limit: 10, period: 1.minute) do |req|
    req.ip if req.post? && submission_route?(req)
  end

  # Is the request to the form submission route?
  def self.submission_route?(req)
    !!(req.path =~ %r{^/touchpoints/\h{1,8}/submissions\.json$}i)
  end

  # Response for throttled requests
  self.throttled_responder = lambda do |env|
    [429, { 'Content-Type' => 'text/plain' }, ['Too many requests. Please try again later.']]
  end
end
