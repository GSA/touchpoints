class CscrmUserPermissions < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :cscrm_data_collection_manager, :boolean, default: false
  end
end
