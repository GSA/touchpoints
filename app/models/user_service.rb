class UserService < ApplicationRecord
  belongs_to :user
  belongs_to :service

  validates :role, presence: true

  module Role
    ServiceManager = "service_manager"
    SubmissionViewer = "submission_viewer"
  end

  ROLES = [
    UserService::Role::ServiceManager,
    UserService::Role::SubmissionViewer
  ]

  def valid_role?
    ROLES.include?(self.role)
  end
end
