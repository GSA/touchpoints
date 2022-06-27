class AddServiceIdToForms < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :service_id, :integer
    add_index :forms, :service_id
  end
end
