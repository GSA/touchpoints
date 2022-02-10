class CollectionSerializer < ActiveModel::Serializer
  attributes :organization_name,
    :id,
    :name,
    :start_date,
    :end_date,
    :organization_id,
    :organization_name,
    :year,
    :quarter,
    :service_provider_id,
    :service_provider_name,
    :user_id

  has_many :omb_cx_reporting_collections
end
