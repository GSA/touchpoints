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
             :service_provider_managers,
             :services_count

  attribute :cx_maturity_mapping_value, if: :service_manager_permissions?
  attribute :impact_mapping_value, if: :service_manager_permissions?

  # TODO: use #service_manager_permissions? in ApplicationController instead
  def service_manager_permissions?
    current_user.service_manager? ||
      current_user.admin?
  end

  def service_provider_managers
    ActiveModel::Serializer::CollectionSerializer.new(object.service_provider_managers, serializer: UserSerializer)
  end
end
