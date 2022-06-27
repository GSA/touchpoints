class AddUserServiceRole < ActiveRecord::Migration[5.2]
  def change
    add_column :user_services, :role, :string
  end
end
