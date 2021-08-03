class Service < ApplicationRecord
  belongs_to :organization
  has_many :service_stages
  belongs_to :service_provider, optional: true
  has_many :collections

  validates :name, presence: true

  scope :hisp, -> { where(hisp: true) }
end
