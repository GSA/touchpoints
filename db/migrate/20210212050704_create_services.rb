class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.integer :organization_id
      t.text :notes

      t.timestamps
    end
  end
end
