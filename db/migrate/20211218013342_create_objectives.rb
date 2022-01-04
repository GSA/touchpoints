class CreateObjectives < ActiveRecord::Migration[6.1]
  def change
    create_table :objectives do |t|
      t.string :name
      t.text :description
      t.integer :organization_id
      t.integer :goal_id
      t.integer :milestone_id
      t.string "tags", array: true
      t.integer "users", array: true
      t.index ["tags"], name: "index_objectives_on_tags", using: :gin
      t.index ["users"], name: "index_objectives_on_users", using: :gin

      t.timestamps
    end
  end
end
