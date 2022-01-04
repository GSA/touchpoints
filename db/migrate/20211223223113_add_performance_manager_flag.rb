class AddPerformanceManagerFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :performance_manager, :boolean, default: false
    add_column :users, :registry_manager, :boolean, default: false
  end
end
