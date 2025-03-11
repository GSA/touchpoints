class RmCxActionPlans < ActiveRecord::Migration[8.0]
  def change
    drop_table :cx_action_plans
  end
end
