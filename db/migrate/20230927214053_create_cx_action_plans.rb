class CreateCxActionPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :cx_action_plans do |t|
      t.integer :service_provider_id
      t.integer :year
      t.text :delivered_current_year
      t.text :to_deliver_next_year

      t.timestamps
    end
  end
end
