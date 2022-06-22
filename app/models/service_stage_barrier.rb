# frozen_string_literal: true

class ServiceStageBarrier < ApplicationRecord
  belongs_to :service_stage
  belongs_to :barrier
end
