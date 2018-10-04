class CreateForms < ActiveRecord::Migration[5.2]
  def change
    create_table :forms do |t|
      t.string :name
      t.integer :organization_id
      t.integer :touchpoint_id
      t.text :notes
      t.string :status

      t.timestamps
    end
  end
end
