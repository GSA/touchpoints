# frozen_string_literal: true

class CxCollection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :service, counter_cache: true
  belongs_to :service_provider
  belongs_to :user
  has_many :cx_collection_details, dependent: :delete_all

  validates :fiscal_year, presence: true
  validates :quarter, presence: true

  validates :name, presence: true

  scope :published, -> { where(aasm_state: 'published') }
  scope :filtered_collections, lambda { |scope, quarter, year, status|
    quarter = quarter.to_i.nonzero?
    year = year.to_i.nonzero?

    items = scope
    items = items.where(quarter: quarter) if quarter && quarter != 0
    items = items.where(fiscal_year: year) if year && year != 0
    items = items.where(aasm_state: status) if status && status.downcase != 'all'
    items = items
      .includes(:organization, :service_provider, :service)
      .references(:organization, :service_provider)
      .order('organizations.name', :fiscal_year, :quarter, 'service_providers.name')
  }

  aasm do
    state :draft, initial: true
    state :submitted
    state :published
    state :not_reported
    state :change_requested
    state :archived

    event :submit do
      transitions from: %i[draft change_requested], to: :submitted, after: :set_submitted_at
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

    event :no_report do
      transitions from: %i[draft submitted], to: :not_reported
    end

    event :reset do
      transitions to: :draft
    end
  end

  def set_submitted_at
    update(submitted_at: Time.current)
  end

  def service_name
    service&.name
  end

  def duplicate!(new_user:)
    new_collection = dup
    new_collection.user = new_user
    new_collection.name = "Copy of #{name}"
    new_collection.rating = nil
    new_collection.aasm_state = :draft
    new_collection.save

    # Loop CX Detail Collections to create them for new_collection
    # cx_collection_details.each do |cx_collection_detail|
    #   cx_collection_detail.save!
    # end

    new_collection
  end

  def self.to_csv
    collections = all.includes(:organization, :service_provider, :service, :user).references(:organization).order(:fiscal_year, :quarter, 'organizations.name')

    attributes = %i[
      id
      name
      organization_id
      organization_name
      organization_abbreviation
      service_provider_id
      service_provider_name
      service_provider_organization_id
      service_provider_organization_name
      service_provider_organization_abbreviation
      service_id
      service_name
      user_email
      fiscal_year
      quarter
      created_at
      updated_at
      submitted_at
      rating
      aasm_state
      integrity_hash
      cx_collection_details_count
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      collections.each do |collection|
        csv << attributes = [
          collection.id,
          collection.name,
          collection.organization_id,
          collection.organization&.name,
          collection.organization&.abbreviation,
          collection.service_provider_id,
          collection.service_provider&.name,
          collection.service_provider&.organization_id,
          collection.service_provider&.organization&.name,
          collection.service_provider&.organization&.abbreviation,
          collection.service_id,
          collection.service&.name,
          collection.user&.email,
          collection.fiscal_year,
          collection.quarter,
          collection.created_at,
          collection.updated_at,
          collection.submitted_at,
          collection.rating,
          collection.aasm_state,
          collection.integrity_hash,
          collection.cx_collection_details.size,
        ]
      end
    end
  end
end
