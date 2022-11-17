class AddWebsiteOrganizationId < ActiveRecord::Migration[7.0]
  def change
    add_column :websites, :organization_id, :integer
    add_index :websites, :organization_id
  end
end
