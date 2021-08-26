class Organization < ApplicationRecord
  has_many :users
  has_many :services
  has_many :forms
  has_many :service_providers
  has_many :collections

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :domain, presence: true
  validates :abbreviation, presence: true
end
