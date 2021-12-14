class DigitalServiceAccountSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :user_id, :service, :service_url, :account, :language, :status, :short_description, :long_description, :tags
end
