class RemoveTouchpoint < ActiveRecord::Migration[5.2]
  def change
    drop_table :touchpoints
    remove_column :submissions, :touchpoint_id
    remove_column :user_roles, :touchpoint_id
  end
end
