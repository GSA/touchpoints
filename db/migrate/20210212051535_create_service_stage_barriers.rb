class CreateServiceStageBarriers < ActiveRecord::Migration[5.2]
  def change
    create_table :service_stage_barriers do |t|
      t.integer :service_stage_id
      t.integer :barrier_id

      t.timestamps
    end
  end
end
