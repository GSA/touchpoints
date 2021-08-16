class AddOrganizationalWebsiteManagerToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :organizational_website_manager, :boolean, default: false
  end
end
