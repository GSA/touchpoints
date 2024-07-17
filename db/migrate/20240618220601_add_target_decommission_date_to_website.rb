class AddTargetDecommissionDateToWebsite < ActiveRecord::Migration[7.1]
  def change
    add_column :websites, :target_decommission_date, :date
  end
end
