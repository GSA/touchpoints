class RemoveOrganizationIdFromContainer < ActiveRecord::Migration[5.2]
  def change
    remove_column :containers, :organization_id
  end
end
