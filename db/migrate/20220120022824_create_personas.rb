class CreatePersonas < ActiveRecord::Migration[6.1]
  def change
    create_table :personas do |t|
      t.string :name
      t.text :description
      t.string :tags, array: true
      t.integer :user_id
      t.text :notes

      t.timestamps
    end

    add_index :personas, :tags, using: 'gin'
  end
end
