# frozen_string_literal: true

class ErrorsController < ApplicationController
  protect_from_forgery with: :null_session
  layout 'public'

  def not_found
    render(status: :not_found)
  end

  def internal_server_error
    render(status: :internal_server_error)
  end
end
