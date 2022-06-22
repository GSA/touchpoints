# frozen_string_literal: true

class CollectionSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :start_date,
             :end_date,
             :organization_id,
             :organization_name,
             :organization_abbreviation,
             :year,
             :quarter,
             :service_provider_id,
             :service_provider_name,
             :integrity_hash,
             :aasm_state,
             :reflection,
             :rating,
             :user_id,
             :updated_at

  has_many :omb_cx_reporting_collections
end
