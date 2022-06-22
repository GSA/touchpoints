# frozen_string_literal: true

class ApiController < ::ApplicationController
  http_basic_authenticate_with name: ENV.fetch('API_HTTP_USERNAME'), password: ENV.fetch('API_HTTP_PASSWORD')
  before_action :set_current_user

  def set_current_user
    api_key = request.headers['X-Api-Key'].presence || params['API_KEY']
    if api_key.present?
      @current_user = User.find_by_api_key(api_key)
      render json: { error: { message: "The API_KEY #{api_key} is not valid." } }, status: :unauthorized unless @current_user
    else
      render json: { error: { message: 'Invalid request. No ?API_KEY= was passed in.' } }, status: :bad_request
    end
  end

  def api_params
    params.require('API_KEY')
  end
end
