class AddHispServiceToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :hisp, :boolean, default: false

    Touchpoint.all.each do |touchpoint|
      next unless touchpoint.service
      touchpoint.update_attribute(:hisp, touchpoint.service.hisp)
    end
  end
end
