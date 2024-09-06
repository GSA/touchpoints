# frozen_string_literal: true

class CxCollectionDetail < ApplicationRecord
  belongs_to :cx_collection
  belongs_to :service_stage, optional: true
  has_many :cx_responses, dependent: :delete_all
  has_one :cx_collection_detail
  has_one :service_provider, through: :cx_collection
  has_one :service, through: :cx_collection

  validates :transaction_point, presence: true
  validates :channel, presence: true

  def volume_of_respondents
    cx_responses.count
  end

  def self.to_csv
    collection_details = CxCollectionDetail.all

    attributes = %i[
      id
      organization_id
      organization_abbreviation
      organization_name
      cx_collection_id
      cx_collection_fiscal_year
      cx_collection_quarter
      cx_collection_name
      cx_collection_service_provider_id
      cx_collection_service_provider_name
      cx_collection_service_provider_slug
      service_id
      service_name
      transaction_point
      channel
      service_stage_id
      service_stage_name
      service_stage_position
      service_stage_count
      volume_of_customers
      volume_of_customers_provided_survey_opportunity
      volume_of_respondents
      omb_control_number
      survey_type
      survey_title
      trust_question_text
      created_at
      updated_at
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      collection_details.each do |collection_detail|
        csv << attributes = [
          collection_detail.id,
          collection_detail.cx_collection.organization_id,
          collection_detail.cx_collection.organization.abbreviation,
          collection_detail.cx_collection.organization.name,

          collection_detail.cx_collection_id,
          collection_detail.cx_collection.fiscal_year,
          collection_detail.cx_collection.quarter,
          collection_detail.cx_collection.name,

          collection_detail.cx_collection.service_provider_id,
          collection_detail.cx_collection.service_provider.name,
          collection_detail.cx_collection.service_provider.slug,

          collection_detail.cx_collection.service_id,
          collection_detail.cx_collection.service.name,

          collection_detail.transaction_point,
          collection_detail.channel,
          collection_detail.service_stage_id,
          collection_detail.service_stage.try(:name),
          collection_detail.service_stage.try(:position),
          collection_detail.cx_collection.service.service_stages.count,

          collection_detail.volume_of_customers,
          collection_detail.volume_of_customers_provided_survey_opportunity,
          collection_detail.volume_of_respondents,

          collection_detail.omb_control_number,
          collection_detail.survey_type,
          collection_detail.survey_title,
          collection_detail.trust_question_text,
          collection_detail.created_at,
          collection_detail.updated_at,
        ]
      end
    end
  end
end
