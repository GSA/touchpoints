class RemoveContainers < ActiveRecord::Migration[5.2]
  def change
    drop_table :containers
    drop_table :triggers
  end
end
