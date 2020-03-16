class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :form

  validates :role, presence: true

  module Role
    FormManager = "form_manager"
    ResponseViewer = "response_viewer"
  end

  ROLES = [
    UserRole::Role::FormManager,
    UserRole::Role::ResponseViewer
  ]

  def valid_role?
    ROLES.include?(self.role)
  end
end
