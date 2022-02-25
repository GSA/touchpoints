class AddUserTitle < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :position_title, :string
    add_column :users, :profile_photo, :string
  end
end
