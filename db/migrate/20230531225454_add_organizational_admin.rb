class AddOrganizationalAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :organizational_admin, :boolean, default: false
  end
end
