class RemoveServicesTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :touchpoints, :service_id
    remove_column :user_roles, :service_id

    drop_table :user_services
    drop_table :services
  end
end
