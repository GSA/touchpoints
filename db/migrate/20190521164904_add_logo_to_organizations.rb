class AddLogoToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :logo, :string
  end
end
