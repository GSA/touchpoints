class ServiceProviderSerializer < ActiveModel::Serializer
  attributes :id,
    :organization_id,
    :organization_abbreviation,
    :organization_name,
    :name,
    :slug,
    :description,
    :notes,
    :department,
    :department_abbreviation,
    :bureau,
    :inactive,
    :url,
    :new
end
