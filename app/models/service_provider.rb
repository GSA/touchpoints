class ServiceProvider < ApplicationRecord
  resourcify
  belongs_to :organization
  has_many :services
  has_many :collections, through: :services
  acts_as_taggable_on :tags

  validates :slug, presence: true

  scope :active, -> { where("inactive ISNULL or inactive = false") }

end
