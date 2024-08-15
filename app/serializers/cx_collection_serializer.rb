class CxCollectionSerializer < ActiveModel::Serializer
  attributes :id,
    :user_id,
    :name,
    :organization_id,
    :service_provider_id,
    :service_id,
    :service_name,
    :fiscal_year,
    :quarter,
    :aasm_state,
    :rating,
    :integrity_hash,
    :created_at,
    :submitted_at,
    :updated_at

end
