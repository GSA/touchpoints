class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :touchpoint, optional: true
  belongs_to :form, optional: true

  validates :role, presence: true

  module Role
    FormManager = "form_manager"
    TouchpointManager = "touchpoint_manager"
    SubmissionViewer = "submission_viewer"
  end

  ROLES = [
    UserRole::Role::FormManager,
    UserRole::Role::TouchpointManager,
    UserRole::Role::SubmissionViewer
  ]

  def valid_role?
    ROLES.include?(self.role)
  end
end
