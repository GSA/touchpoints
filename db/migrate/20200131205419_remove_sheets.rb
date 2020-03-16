class RemoveSheets < ActiveRecord::Migration[5.2]
  def change
    remove_column :touchpoints, :enable_google_sheets
    remove_column :touchpoints, :google_sheet_id
    remove_column :touchpoints, :purpose
    remove_column :touchpoints, :meaningful_response_size
    remove_column :touchpoints, :behavior_change
  end
end
