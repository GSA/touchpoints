module ApplicationHelper

  def suppress_main_layout_flash?
    if flash && ["User successfully added", "User successfully removed"].include?(flash.notice)
      return true
    end
  end

  def is_at_least_service_manager?(user:, service:)
    user.admin? || service.user_role?(user: user) == UserService::Role::ServiceManager
  end
end
