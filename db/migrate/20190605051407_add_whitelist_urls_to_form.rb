class AddWhitelistUrlsToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :whitelist_url, :string, default: ""
    add_column :forms, :whitelist_test_url, :string, default: ""
  end
end
