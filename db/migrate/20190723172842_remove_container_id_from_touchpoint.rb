class RemoveContainerIdFromTouchpoint < ActiveRecord::Migration[5.2]
  def change
    remove_column :touchpoints, :container_id
  end
end
