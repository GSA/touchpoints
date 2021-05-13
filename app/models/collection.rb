class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :user

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
    state :finalized
    state :published
    state :archived

    event :finalize do
     transitions from: :draft, to: :finalized
    end

    event :publish do
     transitions from: :finalized, to: :published
    end

    event :reset do
      transitions to: :draft
    end

  end
end
