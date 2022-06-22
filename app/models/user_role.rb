# frozen_string_literal: true

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :form

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :form_id }

  module Role
    FormManager = 'form_manager'
    ResponseViewer = 'response_viewer'
  end

  ROLES = [
    UserRole::Role::FormManager,
    UserRole::Role::ResponseViewer,
  ].freeze

  def valid_role?
    ROLES.include?(role)
  end
end
