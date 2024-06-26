# frozen_string_literal: true

class ServiceProviderSerializer < ActiveModel::Serializer
  attributes :id,
             :organization_id,
             :organization_abbreviation,
             :organization_name,
             :name,
             :slug,
             :year_designated,
             :description,
             :notes,
             :department,
             :department_abbreviation,
             :bureau,
             :inactive,
             :url,
             :new,
             :portfolio_manager_email,
             :service_provider_managers,
             :services_count

  def show_experimental_fields?
    @instance_options[:show_extra] == true
  end

  attribute :cx_maturity_mapping_value, if: :show_experimental_fields?
  attribute :impact_mapping_value, if: :show_experimental_fields?

  def service_provider_managers
    ActiveModel::Serializer::CollectionSerializer.new(object.service_provider_managers, serializer: UserSerializer)
  end
end
