class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :organization_name, :notes
end
