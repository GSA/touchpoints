module ApplicationHelper

  def suppress_main_layout_flash?
    if flash && ["User successfully added", "User successfully removed"].include?(flash.notice)
      return true
    end
  end
end
