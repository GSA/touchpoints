class CxActionPlanSerializer < ActiveModel::Serializer
  attributes :id, :service_provider_id, :year, :delivered_current_year, :to_deliver_next_year
end
