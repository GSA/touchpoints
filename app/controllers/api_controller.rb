class ApiController < ::ApplicationController
  #http_basic_authenticate_with name: ENV.fetch("API_HTTP_USERNAME"), password: ENV.fetch("API_HTTP_PASSWORD")
  before_action :set_current_user

  def set_current_user
    unless params["API_KEY"]
      render json: { error: { message: "Invalid request. No ?API_KEY= was passed in." } }, status: 400
    else
      @current_user = User.find_by_api_key(api_params)
      unless @current_user
        render json: { error: { message: "The API_KEY #{params['API_KEY']} is not valid." } }, status: 401
      end
    end
  end

  def api_params
    params.require("API_KEY")
  end
end
