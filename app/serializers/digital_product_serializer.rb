# frozen_string_literal: true

class DigitalProductSerializer < ActiveModel::Serializer

  attributes :id,
    :agencies,
    :contacts,
    :service,
    :url,
    :code_repository_url,
    :language,
    :status,
    :short_description,
    :long_description,
    :tags,
    :certified_at

  def agencies
    ActiveModel::Serializer::CollectionSerializer.new(object.sponsoring_agencies, serializer: OrganizationSerializer)
  end

  def contacts
    ActiveModel::Serializer::CollectionSerializer.new(object.contacts, serializer: PublicUserSerializer)
  end

  def status
    object.aasm_state
  end

end
