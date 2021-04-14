class ServiceStage < ApplicationRecord
  belongs_to :service
  has_many :service_stage_barriers
  has_many :barriers, through: :service_stage_barriers

  validates :name, presence: true
end
