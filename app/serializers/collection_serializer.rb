class CollectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :organization_id, :year, :quarter, :user_id, :integrity_hash
end
