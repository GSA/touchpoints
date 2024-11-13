class DeprecateCscrm < ActiveRecord::Migration[7.2]
  def change
    drop_table :cscrm_data_collections
    drop_table :cscrm_data_collections2
    remove_column :users, :cscrm_data_collection_manager
  end
end
