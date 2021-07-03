class Service < ApplicationRecord
  belongs_to :organization
  has_many :service_stages
  has_many :collections

  validates :name, presence: true

  scope :hisp, -> { where(hisp: true) }
end
