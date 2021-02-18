class ServiceStageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :service_id, :notes, :time, :total_eligble_population
end
