class AddFormWhitelistUrls < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :whitelist_url_1, :string
    add_column :forms, :whitelist_url_2, :string
    add_column :forms, :whitelist_url_3, :string
    add_column :forms, :whitelist_url_4, :string
    add_column :forms, :whitelist_url_5, :string
    add_column :forms, :whitelist_url_6, :string
    add_column :forms, :whitelist_url_7, :string
    add_column :forms, :whitelist_url_8, :string
    add_column :forms, :whitelist_url_9, :string
  end
end
