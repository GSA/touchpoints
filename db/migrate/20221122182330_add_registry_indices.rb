class AddRegistryIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :digital_products, :aasm_state
    add_index :digital_service_accounts, :aasm_state
  end
end
