# frozen_string_literal: true

class DigitalServiceAccountSerializer < ActiveModel::Serializer
  attributes :id,
              :name,
              :agencies,
              :contacts,
              :service,
              :service_url,
              :account,
              :language,
              :status,
              :short_description,
              :long_description,
              :tags

  def status
    object.aasm_state
  end

  def agencies
    ActiveModel::Serializer::CollectionSerializer.new(object.sponsoring_agencies, serializer: OrganizationSerializer)
  end

  def contacts
    ActiveModel::Serializer::CollectionSerializer.new(object.contacts, serializer: PublicUserSerializer)
  end

end
