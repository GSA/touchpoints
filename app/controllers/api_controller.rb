class ApiController < ::ApplicationController
  http_basic_authenticate_with name: ENV.fetch("API_HTTP_USERNAME"), password: ENV.fetch("API_HTTP_PASSWORD")
  before_action :set_current_user

  def set_current_user
    api_key = request.headers["X-Api-Key"].present? ? request.headers["X-Api-Key"] : params["API_KEY"]
    unless api_key.present?
      render json: { error: { message: "Invalid request. No ?API_KEY= was passed in." } }, status: 400
    else
      @current_user = User.find_by_api_key(api_key)
      unless @current_user
        render json: { error: { message: "The API_KEY #{api_key} is not valid." } }, status: 401
      end
    end
  end

  def api_params
    params.require("API_KEY")
  end
end
