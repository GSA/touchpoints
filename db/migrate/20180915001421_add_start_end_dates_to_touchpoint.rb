class AddStartEndDatesToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :start_date, :datetime
    add_column :touchpoints, :end_date, :datetime
  end
end
