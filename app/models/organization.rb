class Organization < ApplicationRecord
  has_many :users
  has_many :programs
  has_many :services
  has_many :touchpoints, through: :services

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :domain, presence: true
  validates :abbreviation, presence: true
end
