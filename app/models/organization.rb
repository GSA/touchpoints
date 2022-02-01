class Organization < ApplicationRecord
  acts_as_taggable_on :tags
  has_many :users
  has_many :services
  has_many :forms
  has_many :service_providers
  has_many :collections
  has_many :goals
  has_many :milestones, through: :goals
  has_many :objectives, through: :milestones

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :domain, presence: true
  validates :abbreviation, presence: true

  def slug
    self.abbreviation.downcase
  end

  def to_param
    slug
  end
end
