class Organization < ApplicationRecord
  has_many :users
  has_many :programs
  has_many :services
  has_many :containers
  has_many :touchpoints, through: :containers

  validates :name, presence: true
end
