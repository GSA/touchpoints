# frozen_string_literal: true

class ServiceStageBarrierSerializer < ActiveModel::Serializer
  attributes :id, :service_stage_id, :barrier_id
end
