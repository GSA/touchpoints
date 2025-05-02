class RemoveBarriers < ActiveRecord::Migration[8.0]
  def change
    drop_table :barriers
    drop_table :service_stage_barriers
  end
end
