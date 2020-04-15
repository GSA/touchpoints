class ApplicationController < ActionController::Base

  LEGACY_TOUCHPOINTS_URL_MAP = LegacyTouchpointUrlMap.map

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def after_sign_in_path_for(resource)
    admin_root_path
  end

  # Enforce Permissions
  def ensure_user
    redirect_to(index_path, notice: "Authorization is Required") unless current_user
  end

  def ensure_admin
    redirect_to(index_path, notice: "Authorization is Required") unless admin_permissions?
  end

  def ensure_organization_manager
    redirect_to(index_path, notice: "Authorization is Required") unless organization_manager_permissions?
  end

  helper_method :ensure_form_manager
  def ensure_form_manager(form:)
    return false unless form.present?
    return true if admin_permissions?

    redirect_to(index_path, notice: "Authorization is Required") unless form_permissions?(form: form)
  end

  helper_method :ensure_response_viewer
  def ensure_response_viewer(form:)
    return false unless form.present?
    return true if admin_permissions?
    return true if form_permissions?(form: form)

    redirect_to(index_path, notice: "Authorization is Required") unless response_viewer_permissions?(form: form)
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

  helper_method :form_permissions?
  def form_permissions?(form:)
    return false unless form.present?

    (form.user_role?(user: current_user) == UserRole::Role::FormManager)
  end

  helper_method :response_viewer_permissions?
  def response_viewer_permissions?(form:)
    return false unless form.present?

    (form.user_role?(user: current_user) == UserRole::Role::ResponseViewer) || form_permissions?(form: form)
  end


  # Helpers
  def timestamp_string
    Time.now.strftime('%Y-%m-%d_%H-%M-%S')
  end


  private

  # For Devise
  def after_sign_out_path_for(resource_or_scope)
    index_path
  end
end
