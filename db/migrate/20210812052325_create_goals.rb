class CreateGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :goals do |t|
      t.integer :organization_id
      t.string :name
      t.text :description
      t.string :tags, array: true
      t.integer :users, array: true

      t.timestamps
    end

    add_index :goals, :tags, using: 'gin'
    add_index :goals, :users, using: 'gin'
  end
end
