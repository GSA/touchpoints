class AddServiceIdToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :service_id, :integer
  end
end
