class RemoveOrganizationManagerFlag < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :organization_manager
  end
end
