class ApplicationController < ActionController::Base
  # Enforce Permissions
  def ensure_user
    redirect_to(root_path, notice: "Authorization is Required") unless current_user
  end

  def ensure_admin
    redirect_to(root_path, notice: "Authorization is Required") unless admin_permissions?
  end

  def ensure_organization_manager
    redirect_to(root_path, notice: "Authorization is Required") unless organization_manager_permissions?
  end

  def ensure_service_manager(service:)
    redirect_to(root_path, notice: "Authorization is Required") unless current_user && (organization_manager_permissions? || service.user_role?(user: current_user) == UserService::Role::ServiceManager)
  end


  # Define Permissions
  helper_method :admin_permissions?
  def admin_permissions?
    current_user && current_user.admin?
  end

  helper_method :organization_manager_permissions?
  def organization_manager_permissions?
    current_user && (current_user.admin? || current_user.organization_manager?)
  end


  # Helpers
  def timestamp_string
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end
end
