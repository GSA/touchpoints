class AddServiceIdToContainer < ActiveRecord::Migration[5.2]
  def change
    add_column :containers, :service_id, :integer, null: false
  end
end
