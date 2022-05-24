class DigitalProductSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :user_id, :service, :url, :code_repository_url, :language, :status, :aasm_state, :short_description, :long_description, :tags, :certified_at
end
