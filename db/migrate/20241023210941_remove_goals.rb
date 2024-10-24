class RemoveGoals < ActiveRecord::Migration[7.2]
  def change
    drop_table :goals
    drop_table :goal_targets
    drop_table :objectives
    drop_table :milestones
  end
end
