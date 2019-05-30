class Organization < ApplicationRecord
  has_many :users
  has_many :programs
  has_many :services
  has_many :service_locations
  has_many :containers, through: :services
  has_many :touchpoints, through: :containers

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :domain, presence: true
end
