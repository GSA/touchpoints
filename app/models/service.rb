require 'csv'

class Service < ApplicationRecord
  resourcify
  include AASM
  has_paper_trail

  belongs_to :organization
  belongs_to :service_provider
  has_many :service_stages
  has_many :omb_cx_reporting_collections
  has_many :collections, through: :omb_cx_reporting_collections
  acts_as_taggable_on :tags

  validates :name, presence: true
  validates :service_owner_id, presence: true

  scope :hisp, -> { where(hisp: true) }

  after_create :create_default_service_stages
  after_create :create_roles

  aasm do
    state :created, initial: true
    state :submitted
    state :approved
    state :verified
    state :archived

    event :submit do
      transitions from: [:created], to: :submitted
    end
    event :approve do
      transitions from: [:submitted], to: :approved
    end
    event :verify do
      transitions from: [:approved], to: :verified
    end
    event :archive do
      transitions from: [:verified], to: :archived
    end
    event :reset do
      transitions to: :created
    end
  end

  def create_default_service_stages
    self.service_stages.create(position: 10, name: :start)
    self.service_stages.create(position: 20, name: :process)
    self.service_stages.create(position: 100, name: :end)
  end

  def create_roles
    service_owner.add_role :service_manager, self
  end

  def owner?(user:)
    return false unless user

    user.admin? || self.service_owner_id == user.id
  end

  def service_owner
    return nil unless self.service_owner_id

    User.find_by_id(self.service_owner_id)
  end

  def service_managers
    User.with_role(:service_manager, self)
  end

  def service_owner_email
    service_owner && service_owner.try(:email)
  end

  def organization_name
    self.organization ? self.organization.name : nil
  end

  def service_provider_name
    self.service_provider ? self.service_provider.name : nil
  end

  def self.to_csv
    services = Service.order("organizations.name").includes(:organization)

    example_service_attributes = Service.new.attributes
    attributes = example_service_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << attributes

      services.each do |service|
        csv << attributes.map { |attr| service.send(attr) }
      end
    end
  end
end
