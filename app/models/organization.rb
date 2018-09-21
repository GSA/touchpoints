class Organization < ApplicationRecord
  has_many :users
  has_many :touchpoints

  validates :name, presence: true
end
