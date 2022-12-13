# frozen_string_literal: true

class ApplicationController < ActionController::Base
  LEGACY_TOUCHPOINTS_URL_MAP = LegacyTouchpointUrlMap.map

  around_action :switch_locale

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def fiscal_year(date)
    (date - 3.months).year
  end

  def fiscal_quarter(date)
    if [10, 11, 12].include?(date.month)
      1
    elsif [1, 2, 3].include?(date.month)
      2
    elsif [4, 5, 6].include?(date.month)
      3
    elsif [7, 8, 9].include?(date.month)
      4
    end
  end

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  # Enforce Permissions
  #
  # `ensure_` methods are responsible for checking permissions and redirecting if necessary
  #
  def ensure_user
    unless current_user
      store_location_for(:user, request.fullpath)
      redirect_to(index_path, notice: 'Authorization is Required')
    end
  end

  def ensure_admin
    return true if admin_permissions?

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_admin_or_contact(obj)
    return true if admin_permissions?

    return true if current_user.present? && current_user.has_role?(:contact, obj)

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_performance_manager_permissions
    return true if performance_manager_permissions?

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_collection_owner(collection:)
    return false if collection.blank?
    return true if admin_permissions?
    return true if collection_permissions?(collection:)

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_form_manager(form:)
    return false if form.blank?
    return true if form_permissions?(form:)

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_response_viewer(form:)
    return false if form.blank?
    return true if admin_permissions?
    return true if form_permissions?(form:)
    return true if response_viewer_permissions?(form:)

    redirect_to(index_path, notice: 'Authorization is Required')
  end

  def ensure_service_manager_permissions
    return true if service_manager_permissions?

    redirect_to(admin_services_path, notice: 'Authorization is Required')
  end

  def ensure_service_owner(service:, user:)
    return false if user.blank?
    return true if service_permissions?(service:)

    redirect_to(admin_services_path, notice: 'Authorization is Required')
  end

  def ensure_website_admin(website:)
    return false if current_user.blank?
    return true if website_permissions?(website:, user: current_user)

    redirect_to(admin_websites_path, notice: 'Authorization is Required')
  end

  def ensure_organizational_website_manager
    return false if current_user.blank?
    return true if organizational_website_manager_permissions?(user: current_user)

    redirect_to(admin_root_path, notice: 'Authorization is Required')
  end

  def ensure_registry_manager
    return false if current_user.blank?
    return true if registry_manager_permissions?(user: current_user)

    redirect_to(admin_root_path, notice: 'Authorization is Required')
  end

  def ensure_digital_service_account_permissions(digital_service_account:)
    return false if current_user.blank?
    return true if digital_service_account_permissions?(digital_service_account:, user: current_user)

    redirect_to(admin_root_path, notice: 'Authorization is Required')
  end

  def ensure_digital_product_permissions(digital_product:)
    return false if current_user.blank?
    return true if digital_product_permissions?(digital_product:, user: current_user)

    redirect_to(admin_root_path, notice: 'Authorization is Required')
  end

  # Define Permissions
  helper_method :admin_permissions?
  def admin_permissions?
    current_user&.admin?
  end

  helper_method :performance_manager_permissions?
  def performance_manager_permissions?
    return false if current_user.blank?
    return true if admin_permissions?

    current_user.performance_manager?
  end

  helper_method :collection_permissions?
  def collection_permissions?(collection:)
    return false if collection.blank?
    return true if performance_manager_permissions?

    collection.organization == current_user.organization
  end

  helper_method :website_permissions?
  def website_permissions?(website:, user:)
    return false if website.blank?
    return false if user.blank?

    website.admin?(user:)
  end

  helper_method :organizational_website_manager_permissions?
  def organizational_website_manager_permissions?(user:)
    return false if user.blank?
    return true if admin_permissions?

    user.organizational_website_manager?
  end

  helper_method :registry_manager_permissions?
  def registry_manager_permissions?(user:)
    return false if user.blank?
    return true if admin_permissions?

    user.registry_manager?
  end

  helper_method :digital_service_account_permissions?
  def digital_service_account_permissions?(digital_service_account:, user:)
    return false if user.blank?
    return true if registry_manager_permissions?(user: current_user)

    user.has_role?(:contact, digital_service_account)
  end

  helper_method :digital_product_permissions?
  def digital_product_permissions?(digital_product:, user:)
    return false if user.blank?
    return true if registry_manager_permissions?(user:)

    user.has_role?(:contact, digital_product)
  end

  helper_method :service_permissions?
  def service_permissions?(service:)
    return false if service.blank?
    return true if current_user.has_role?(:service_manager, service)
    return true if service_manager_permissions?
    return true if admin_permissions?

    service.owner?(user: current_user)
  end

  helper_method :service_manager_permissions?
  def service_manager_permissions?
    return false if current_user.blank?
    return true if current_user.service_manager?
    return true if admin_permissions?

    false
  end

  helper_method :form_permissions?
  def form_permissions?(form:)
    return false if form.blank?
    return true if admin_permissions?
    return true if current_user.has_role?(:form_manager, form)

    (form.user_role?(user: current_user) == UserRole::Role::FormManager)
  end

  helper_method :response_viewer_permissions?
  def response_viewer_permissions?(form:)
    return false if form.blank?

    (form.user_role?(user: current_user) == UserRole::Role::ResponseViewer) || form_permissions?(form:)
  end

  # Helpers
  def timestamp_string
    Time.zone.now.strftime('%Y-%m-%d_%H-%M-%S')
  end

  def paginate(scope, default_per_page = 20)
    collection = scope.page(params[:page]).per((params[:per_page] || default_per_page).to_i)

    current = collection.current_page
    total = collection.num_pages
    per_page = collection.limit_value

    [{
      pagination: {
        current:,
        previous: (current > 1 ? (current - 1) : nil),
        next: (current == total ? nil : (current + 1)),
        per_page:,
        pages: total,
        count: collection.total_count,
      },
    }, collection]
  end

  # customized response for `#verify_authenticity_token`
  def handle_unverified_request
    render json: { messages: { submission: ["invalid CSRF authenticity token"] } }, status: :unprocessable_entity
  end


  private

  # For Devise
  def after_sign_out_path_for(_resource_or_scope)
    index_path
  end

  def after_sign_in_path_for(resource_or_scope)
    redirect_url = stored_location_for(resource_or_scope)
    if redirect_url.present?
      "#{request.base_url}#{redirect_url}"
    else
      super
    end
  end
end
