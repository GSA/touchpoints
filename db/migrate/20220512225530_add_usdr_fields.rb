class AddUsdrFields < ActiveRecord::Migration[7.0]
  def change
    add_column :digital_service_accounts, :name, :string
  end
end
