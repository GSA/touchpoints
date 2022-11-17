# frozen_string_literal: true

class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :service_provider
  belongs_to :user
  has_many :omb_cx_reporting_collections, dependent: :delete_all

  validates :year, presence: true
  validates :quarter, presence: true

  validates :name, presence: true
  validates :reflection, length: { maximum: 5000 }

  scope :published, -> { where(aasm_state: 'published') }

  def omb_control_number
    'omb_control_number'
  end

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

  def duplicate!(new_user:)
    new_collection = dup
    new_collection.user = new_user
    new_collection.name = "Copy of #{name}"
    new_collection.start_date = nil
    new_collection.end_date = nil
    new_collection.reflection = nil
    new_collection.rating = nil
    new_collection.aasm_state = :draft
    new_collection.save

    # Loop OMB CX Reporting Collections to create them for new_collection
    omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
      new_omb_cx_reporting_collection = omb_cx_reporting_collection.dup
      new_omb_cx_reporting_collection.collection = new_collection
      new_omb_cx_reporting_collection.volume_of_customers = 0
      new_omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity = 0
      new_omb_cx_reporting_collection.volume_of_respondents = 0
      new_omb_cx_reporting_collection.q1_1 = 0
      new_omb_cx_reporting_collection.q1_2 = 0
      new_omb_cx_reporting_collection.q1_3 = 0
      new_omb_cx_reporting_collection.q1_4 = 0
      new_omb_cx_reporting_collection.q1_5 = 0
      new_omb_cx_reporting_collection.q2_1 = 0
      new_omb_cx_reporting_collection.q2_2 = 0
      new_omb_cx_reporting_collection.q2_3 = 0
      new_omb_cx_reporting_collection.q2_4 = 0
      new_omb_cx_reporting_collection.q2_5 = 0
      new_omb_cx_reporting_collection.q3_1 = 0
      new_omb_cx_reporting_collection.q3_2 = 0
      new_omb_cx_reporting_collection.q3_3 = 0
      new_omb_cx_reporting_collection.q3_4 = 0
      new_omb_cx_reporting_collection.q3_5 = 0
      new_omb_cx_reporting_collection.q4_1 = 0
      new_omb_cx_reporting_collection.q4_2 = 0
      new_omb_cx_reporting_collection.q4_3 = 0
      new_omb_cx_reporting_collection.q4_4 = 0
      new_omb_cx_reporting_collection.q4_5 = 0
      new_omb_cx_reporting_collection.q5_1 = 0
      new_omb_cx_reporting_collection.q5_2 = 0
      new_omb_cx_reporting_collection.q5_3 = 0
      new_omb_cx_reporting_collection.q5_4 = 0
      new_omb_cx_reporting_collection.q5_5 = 0
      new_omb_cx_reporting_collection.q6_1 = 0
      new_omb_cx_reporting_collection.q6_2 = 0
      new_omb_cx_reporting_collection.q6_3 = 0
      new_omb_cx_reporting_collection.q6_4 = 0
      new_omb_cx_reporting_collection.q6_5 = 0
      new_omb_cx_reporting_collection.q7_1 = 0
      new_omb_cx_reporting_collection.q7_2 = 0
      new_omb_cx_reporting_collection.q7_3 = 0
      new_omb_cx_reporting_collection.q7_4 = 0
      new_omb_cx_reporting_collection.q7_5 = 0
      new_omb_cx_reporting_collection.q8_1 = 0
      new_omb_cx_reporting_collection.q8_2 = 0
      new_omb_cx_reporting_collection.q8_3 = 0
      new_omb_cx_reporting_collection.q8_4 = 0
      new_omb_cx_reporting_collection.q8_5 = 0
      new_omb_cx_reporting_collection.q9_1 = 0
      new_omb_cx_reporting_collection.q9_2 = 0
      new_omb_cx_reporting_collection.q9_3 = 0
      new_omb_cx_reporting_collection.q9_4 = 0
      new_omb_cx_reporting_collection.q9_5 = 0
      new_omb_cx_reporting_collection.q10_1 = 0
      new_omb_cx_reporting_collection.q10_2 = 0
      new_omb_cx_reporting_collection.q10_3 = 0
      new_omb_cx_reporting_collection.q10_4 = 0
      new_omb_cx_reporting_collection.q10_5 = 0
      new_omb_cx_reporting_collection.q11_1 = 0
      new_omb_cx_reporting_collection.q11_2 = 0
      new_omb_cx_reporting_collection.q11_3 = 0
      new_omb_cx_reporting_collection.q11_4 = 0
      new_omb_cx_reporting_collection.q11_5 = 0
      new_omb_cx_reporting_collection.save!
    end

    new_collection
  end

  def totals
    @volume_of_customers = 0
    @volume_of_customers_provided_survey_opportunity = 0
    @volume_of_respondents = 0

    omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
      @volume_of_customers += omb_cx_reporting_collection.volume_of_customers.to_i
      @volume_of_customers_provided_survey_opportunity += omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity.to_i
      @volume_of_respondents += omb_cx_reporting_collection.volume_of_respondents.to_i
    end

    {
      volume_of_customers: @volume_of_customers,
      volume_of_customers_provided_survey_opportunity: @volume_of_customers_provided_survey_opportunity,
      volume_of_respondents: @volume_of_respondents,
    }
  end

  def self.to_csv
    collections = Collection.all.order(:year, :quarter, 'organizations.name').includes(:organization)

    attributes = %i[
      id
      name
      start_date
      end_date
      service_provider_id
      service_provider_name
      organization_id
      organization_name
      user_email
      year
      quarter
      reflection
      created_at
      updated_at
      rating
      aasm_state
      integrity_hash
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      collections.each do |collection|
        csv << attributes = [
          collection.id,
          collection.name,
          collection.start_date,
          collection.end_date,
          collection.service_provider_id,
          collection.service_provider.name,
          collection.organization_id,
          collection.organization.name,
          collection.user.email,
          collection.year,
          collection.quarter,
          collection.reflection,
          collection.created_at,
          collection.updated_at,
          collection.rating,
          collection.aasm_state,
          collection.integrity_hash,
        ]
      end
    end
  end

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true

  delegate :name, to: :service_provider, prefix: true
end
