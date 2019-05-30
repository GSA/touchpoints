class ApplicationController < ActionController::Base
  def ensure_user
    redirect_to(root_path, notice: "Authorization is Required") unless current_user
  end

  def ensure_admin
    redirect_to(root_path, notice: "Authorization is Required") unless current_user && current_user.admin?
  end

  def ensure_organization_manager
    redirect_to(root_path, notice: "Authorization is Required") unless current_user && (current_user.admin? || current_user.organization_manager?)
  end

  def ensure_service_manager(service:)
    redirect_to(root_path, notice: "Authorization is Required") unless current_user && (current_user.admin? || current_user.organization_manager? || service.user_role?(user: current_user) == UserService::Role::ServiceManager)
  end

  def timestamp_string
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end
end
