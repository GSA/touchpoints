class CxCollection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :service
  belongs_to :service_provider
  belongs_to :user
  has_many :cx_collection_details

  validates :fiscal_year, presence: true
  validates :quarter, presence: true

  validates :name, presence: true
  validates :reflection, length: { maximum: 5000 }

  scope :published, -> { where(aasm_state: 'published') }

  aasm do
    state :draft, initial: true
    state :submitted
    state :published
    state :change_requested
    state :archived

    event :submit do
        transitions from: %i[draft change_requested], to: :submitted
    end

    event :publish do
      transitions from: :submitted, to: :published
    end

    event :request_change do
      transitions from: [:submitted], to: :change_requested
    end

    event :archive do
      transitions from: [:published], to: :archived
    end

    event :reset do
      transitions to: :draft
    end
  end
end
