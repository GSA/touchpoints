class ServiceProviderSerializer < ActiveModel::Serializer
  attributes :id,
    :organization_id,
    :organization_name,
    :name,
    :slug,
    :description,
    :notes,
    :department,
    :department_abbreviation,
    :bureau,
    :bureau_abbreviation,
    :inactive,
    :url,
    :new
end
