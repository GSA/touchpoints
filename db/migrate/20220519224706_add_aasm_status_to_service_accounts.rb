class AddAasmStatusToServiceAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :digital_service_accounts, :aasm_state, :string
    rename_column :digital_products, :aasm_status, :aasm_state
  end
end
