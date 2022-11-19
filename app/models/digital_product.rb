# frozen_string_literal: true

require 'json'
require 'open-uri'

class DigitalProduct < ApplicationRecord
  include AASM
  has_paper_trail
  resourcify
  acts_as_taggable_on :tags, :organizations

  has_many :digital_product_versions

  validates :name, presence: true

  scope :active, -> { where(aasm_state: :published) }

  aasm do
    state :created, initial: true
    state :updated
    state :submitted
    state :under_review # TODO: CLEANUP, by consolidating to "submitted"
    state :published
    state :archived

    event :submit do
      transitions from: [:created, :updated], to: :submitted
    end
    event :publish do
      transitions from: [:submitted, :under_review], to: :published
    end
    event :archive do
      transitions to: :archived
    end
    event :update_state do
      transitions to: :updated
    end
    event :reset do
      transitions to: :created
    end
  end

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end
end
