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
             :notes,
             :hisp,
             :department,
             :bureau,
             :service_abbreviation,
             :service_slug,
             :service_owner_email,
             :service_managers,
             :url,
             :channels,
             :tags

  def service_managers
    ActiveModel::Serializer::ArraySerializer.new(object.service_managers, each_serializer: UserSerializer)
  end
end
