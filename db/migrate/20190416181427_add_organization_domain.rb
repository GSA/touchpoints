class AddOrganizationDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :domain, :string
  end
end
