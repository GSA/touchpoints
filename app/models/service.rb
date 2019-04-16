class Service < ApplicationRecord
  belongs_to :organization
  has_many :user_services
  has_many :users,  through: :user_services
  
  validates :name, presence: true
end
