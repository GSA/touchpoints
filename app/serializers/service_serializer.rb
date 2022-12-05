# frozen_string_literal: true

class ServiceSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :description,
             :organization_id,
             :organization_abbreviation,
             :organization_name,
             :service_provider_id,
             :service_provider_name,
             :justification_text,
             :kind,
             :transactional,
             :notes,
             :hisp,
             :department,
             :bureau,
             :service_abbreviation,
             :service_slug,
             :service_owner_email,
             :service_managers,
             :url,
             :homepage_url,
             :channels,
             :tags,
             :available_in_person,
             :available_digitally,
             :available_via_phone

  def service_managers
    ActiveModel::Serializer::CollectionSerializer.new(object.service_managers, serializer: UserSerializer)
  end

  def available_in_person
    object.available_in_person?
  end

  def available_digitally
    object.available_digitally?
  end

  def available_via_phone
    object.available_via_phone?
  end
end
