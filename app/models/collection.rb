class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :user
  has_many :omb_cx_reporting_collections

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
end
