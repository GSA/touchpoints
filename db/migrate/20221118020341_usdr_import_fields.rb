class UsdrImportFields < ActiveRecord::Migration[7.0]
  def change
    add_column :digital_products, :legacy_id, :integer
    add_column :digital_products, :legacy_notes, :text

    add_column :digital_product_versions, :legacy_id, :integer
    add_column :digital_product_versions, :legacy_notes, :text

    add_column :digital_service_accounts, :legacy_id, :integer
    add_column :digital_service_accounts, :legacy_notes, :text
  end
end
