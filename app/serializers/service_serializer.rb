class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :organization_id, :notes
end
