class AddOrganizationManagerToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization_manager, :boolean, default: false
  end
end
