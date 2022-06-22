# frozen_string_literal: true

class Barrier < ApplicationRecord
  has_many :service_stage_barriers
  has_many :service_stages, through: :service_stage_barriers
end
