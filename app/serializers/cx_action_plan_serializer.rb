class CxActionPlanSerializer < ActiveModel::Serializer
  attributes :id,
    :organization_id,
    :organization_name,
    :service_provider_id,
    :service_provider_name,
    :year,
    :delivered_current_year,
    :to_deliver_next_year,
    :services


  def services
    ActiveModel::Serializer::CollectionSerializer.new(object.services, serializer: ServiceSerializer)
  end
end
