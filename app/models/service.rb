class Service < ApplicationRecord
  belongs_to :organization
  belongs_to :service_provider
  has_many :service_stages
  has_many :omb_cx_reporting_collections
  has_many :collections, through: :omb_cx_reporting_collections

  validates :name, presence: true

  scope :hisp, -> { where(hisp: true) }

  after_create :create_default_service_stages

  def create_default_service_stages
    self.service_stages.create(position: 10, name: :start)
    self.service_stages.create(position: 20, name: :process)
    self.service_stages.create(position: 100, name: :end)
  end
end
