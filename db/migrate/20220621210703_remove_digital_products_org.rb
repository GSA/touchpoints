class RemoveDigitalProductsOrg < ActiveRecord::Migration[7.0]
  def change
    remove_column :digital_products, :organization_id
    remove_column :digital_service_accounts, :organization_id
  end
end
