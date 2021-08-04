class Service < ApplicationRecord
  belongs_to :organization
  belongs_to :service_provider, optional: true
  has_many :service_stages
  has_many :omb_cx_reporting_collections
  has_many :collections, through: :omb_cx_reporting_collections

  validates :name, presence: true

  scope :hisp, -> { where(hisp: true) }
end
