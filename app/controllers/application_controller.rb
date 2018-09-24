class ApplicationController < ActionController::Base

  def ensure_user
    redirect_to(root_path, notice: "Authorization is Required") unless current_user
  end

  def ensure_admin
    redirect_to(root_path, notice: "Authorization is Required") unless current_user && current_user.admin?
  end
end
