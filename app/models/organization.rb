class Organization < ApplicationRecord
  has_many :users
  has_many :forms

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :domain, presence: true
  validates :abbreviation, presence: true

  def managers
    users.where(organization_manager: true)
  end
end
