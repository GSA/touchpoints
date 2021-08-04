class ServiceProviderSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :name, :description, :notes, :department, :department_abbreviation, :bureau, :bureau_abbreviation
end
