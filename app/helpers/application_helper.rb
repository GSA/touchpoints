module ApplicationHelper

  def suppress_main_layout_flash?
    if flash && ["User successfully added", "User successfully removed"].include?(flash.notice)
      return true
    end
  end

  def is_at_least_organization_manager?(user:)
    user.admin? || user.organization_manager?
  end

  def is_at_least_service_manager?(user:, service:)
    user.admin? || user.organization_manager? ||
      service.user_role?(user: user) == UserService::Role::ServiceManager
  end

  def current_path
    request.fullpath
  end
end
