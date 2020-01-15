class ApplicationController < ActionController::Base

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def after_sign_in_path_for(resource)
    admin_root_path
  end

  def submit_touchpoint_url(touchpoint)
    return "#{root_url}touchpoints/#{touchpoint.uuid}/submit"
  end

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

  helper_method :ensure_touchpoint_manager
  def ensure_touchpoint_manager(touchpoint:)
    return false unless touchpoint.present?

    redirect_to(root_path, notice: "Authorization is Required") unless touchpoint_permissions?(touchpoint: touchpoint)
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

  helper_method :touchpoint_permissions?
  def touchpoint_permissions?(touchpoint:)
    return false unless touchpoint.present?

    (touchpoint.user_role?(user: current_user) == UserRole::Role::TouchpointManager) || admin_permissions?
  end


  # Helpers
  def timestamp_string
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end
end
