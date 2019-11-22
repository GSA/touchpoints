class ErrorsController < ActionController::Base
  protect_from_forgery with: :null_session

  def not_found

  end

  def internal_server_error

  end
end