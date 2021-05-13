class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :user

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
