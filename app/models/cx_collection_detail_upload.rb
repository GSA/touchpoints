class CxCollectionDetailUpload < ApplicationRecord
  belongs_to :user
  belongs_to :cx_collection_detail

  aasm do
    state :created, initial: true
    state :processing
    state :processed

    event :process do
      transitions from: [:created], to: :processing
    end
    event :complete do
      transitions from: [:processing], to: :processed
    end
    event :reset do
      transitions to: :created
    end
  end
end
