class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description,
    :organization_name,
    :service_provider_name,
    :notes
end
