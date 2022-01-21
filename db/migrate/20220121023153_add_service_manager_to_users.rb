class AddServiceManagerToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :service_manager, :boolean, default: false
  end
end
