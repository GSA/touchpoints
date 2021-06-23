class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :user
  has_many :omb_cx_reporting_collections

  validates :year, presence: true
  validates :quarter, presence: true

  after_create :generate_supporting_elements

  validates :name, presence: true

  def generate_supporting_elements
    if self.name.include?("CX Quarterly")
      OmbCxReportingCollection.create!({
        collection_id: self.id,
        service_provided: "Description of your service"
      })
    end
  end

  aasm do
    state :draft, initial: true
    state :submitted
    state :published
    state :change_requested
    state :archived

    event :submit do
     transitions from: :draft, to: :submitted
    end

    event :publish do
     transitions from: :submitted, to: :published
    end

    event :request_change do
      transitions to: :change_requested
    end

    event :archive do
      transitions to: :archived
    end

    event :reset do
      transitions to: :draft
    end

  end

  def duplicate!(user:)
    new_collection = self.dup
    new_collection.user = user
    new_collection.name = "Copy of #{self.name}"
    new_collection.quarter = nil
    new_collection.aasm_state = :draft
    new_collection.save

    # Loop OMB CX Reporting Collections to create them for new_collection
    self.omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
      new_omb_cx_reporting_collection = omb_cx_reporting_collection.dup
      new_omb_cx_reporting_collection.collection = new_collection
      new_omb_cx_reporting_collection.save!
    end

    return new_collection
  end
end
