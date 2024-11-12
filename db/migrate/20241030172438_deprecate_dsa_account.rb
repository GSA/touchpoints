class DeprecateDsaAccount < ActiveRecord::Migration[7.2]
  def change
    remove_column :digital_service_accounts, :account
  end
end
