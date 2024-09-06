# frozen_string_literal: true

class CxActionPlan < ApplicationRecord
  belongs_to :service_provider

  delegate :organization_id, to: :service_provider

  def organization_name
    service_provider.organization.name
  end

  delegate :name, to: :service_provider, prefix: true

  delegate :services, to: :service_provider
end
