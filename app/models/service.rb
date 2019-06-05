class Service < ApplicationRecord
  belongs_to :organization
  has_many :touchpoints
  has_many :user_services
  has_many :users, through: :user_services

  validates :name, presence: true

  def user_role?(user:)
    user_service = self.user_services.find_by_user_id(user.id)
    user_service.role
  end
end
