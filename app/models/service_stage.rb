# frozen_string_literal: true

class ServiceStage < ApplicationRecord
  belongs_to :service, counter_cache: true
  belongs_to :persona, optional: true
  has_many :service_stage_barriers
  has_many :barriers, through: :service_stage_barriers

  validates :name, presence: true

  def self.to_csv
    service_stages = ServiceStage.order('organizations.name').includes([:organization, :service, :taggings])

    example_attributes = ServiceStage.new.attributes
    attributes = example_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << attributes

      service_stages.each do |service|
        csv << attributes.map { |attr| service.send(attr) }
      end
    end
  end
end
