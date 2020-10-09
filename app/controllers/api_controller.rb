class ApiController < ::ApplicationController
  http_basic_authenticate_with name: ENV.fetch("API_HTTP_USERNAME"), password: ENV.fetch("API_HTTP_PASSWORD")
end
