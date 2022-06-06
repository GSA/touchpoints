class ServiceStage < ApplicationRecord
  belongs_to :service
  belongs_to :persona, optional: true
  has_many :service_stage_barriers
  has_many :barriers, through: :service_stage_barriers

  validates :name, presence: true
end
