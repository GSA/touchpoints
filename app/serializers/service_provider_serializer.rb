# frozen_string_literal: true

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
             :new,
             :service_provider_managers

   def service_provider_managers
     ActiveModel::Serializer::ArraySerializer.new(object.service_provider_managers, each_serializer: UserSerializer)
   end
end
