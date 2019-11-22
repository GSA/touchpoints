class ErrorsController < ApplicationController
  protect_from_forgery with: :null_session
  layout false

  def not_found
  	render(status: 404)
  end

  def internal_server_error
  	render(status: 500)
  end
end