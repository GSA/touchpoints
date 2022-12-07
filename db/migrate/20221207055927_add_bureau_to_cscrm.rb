class AddBureauToCscrm < ActiveRecord::Migration[7.0]
  def change
    add_column :cscrm_data_collections, :bureau_id, :integer
  end
end
