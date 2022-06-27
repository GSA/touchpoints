class CreateGoalTargets < ActiveRecord::Migration[6.1]
  def change
    create_table :goal_targets do |t|
      t.integer :goal_id
      t.datetime :target_date_at
      t.text :assertion
      t.string :kpi
      t.integer :starting_value
      t.integer :target_value
      t.integer :current_value

      t.timestamps
    end
  end
end
