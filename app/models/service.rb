class Service < ApplicationRecord
  include AASM
  has_paper_trail

  belongs_to :organization
  belongs_to :service_provider
  has_many :service_stages
  has_many :omb_cx_reporting_collections
  has_many :collections, through: :omb_cx_reporting_collections
  acts_as_taggable_on :tags

  validates :name, presence: true

  scope :hisp, -> { where(hisp: true) }

  after_create :create_default_service_stages

  aasm do
    state :created, initial: true
    state :submitted
    state :approved
    state :live
    state :archived

    event :submit do
      transitions from: [:created], to: :submitted
    end
    event :approve do
      transitions from: [:submitted], to: :approved
    end
    event :activate do
      transitions from: [:approved], to: :live
    end
    event :archive do
      transitions from: [:live], to: :archived
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

  def owner?(user:)
    return false unless user

    user.admin? || self.service_owner_id == user.id
  end

  def service_owner
    return false unless self.service_owner_id

    User.find_by_id(self.service_owner_id)
  end

  def organization_name
    self.organization ? self.organization.name : nil
  end
end
