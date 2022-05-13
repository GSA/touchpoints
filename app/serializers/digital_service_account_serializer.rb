class DigitalServiceAccountSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :organization_id,
    :organization_name,
    :organization_abbreviation,
    :user_id,
    :service,
    :service_url,
    :account,
    :language,
    :status,
    :short_description,
    :long_description,
    :tags
end
