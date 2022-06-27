class AddInactiveToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :inactive, :boolean
  end
end
