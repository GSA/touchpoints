class Service < ApplicationRecord
  belongs_to :organization
  has_one :container
  has_many :touchpoints
  has_many :user_services
  has_many :users, through: :user_services

  validates :name, presence: true

  def create_container!
    return unless Rails.env.test?
    return unless self.container

    Container.create!({
      service: self,
      name: "#{self.name} Container",
    })
  end

  def user_role?(user:)
    user_service = self.user_services.find_by_user_id(user.id)
    user_service.role
  end
end
