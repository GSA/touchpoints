# frozen_string_literal: true

class ServiceStageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :service_id, :notes, :time, :total_eligible_population
end
