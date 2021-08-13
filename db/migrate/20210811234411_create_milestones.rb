class CreateMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :milestones do |t|
      t.integer :organization_id
      t.integer :goal_id
      t.string :name
      t.text :description
      t.date :due_date
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
