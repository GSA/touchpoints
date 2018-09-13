class ApplicationController < ActionController::Base

  def ensure_user
    redirect_to root_path unless current_user
  end
end
