# frozen_string_literal: true

class ServiceStage < ApplicationRecord
  belongs_to :service, counter_cache: true
  belongs_to :persona, optional: true
  has_many :service_stage_barriers
  has_many :barriers, through: :service_stage_barriers

  validates :name, presence: true

  def self.to_csv
    service_stages = ServiceStage.order('service_id', 'position')

    example_attributes = ServiceStage.new.attributes
    attributes = example_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << (attributes + %w[service_name service_provider_id service_provider_name])

      service_stages.each do |stage|
        csv << (attributes.map { |attr| stage.send(attr) } + [stage.service.name, stage.service.try(:service_provider).try(:id), stage.service.try(:service_provider).try(:name)])
      end
    end
  end
end
