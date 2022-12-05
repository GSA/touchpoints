class RemoveRegistryStatusFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :digital_products, :status
    remove_column :digital_service_accounts, :status
  end
end
