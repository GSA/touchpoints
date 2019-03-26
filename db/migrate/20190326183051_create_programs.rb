class CreatePrograms < ActiveRecord::Migration[5.2]
  def change
    create_table :programs do |t|
      t.string :name
      t.integer :organization_id
      t.string :url

      t.timestamps
    end
  end
end
