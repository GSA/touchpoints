class AddApiKeyUpdateDateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_key_updated_at, :datetime
  end
end
