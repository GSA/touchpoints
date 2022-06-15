# frozen_string_literal: true

class AddTouchpointOrganizationId < ActiveRecord::Migration[5.2]
  def up
    add_column :touchpoints, :organization_id, :integer

    Touchpoint.all.each do |touchpoint|
      next if touchpoint.service.blank?

      Rails.logger.debug { "Updating Touchpoint organization_id #{touchpoint.id}" }
      touchpoint.update_attribute(:organization_id, touchpoint.service.organization_id)
    end
  end
end
