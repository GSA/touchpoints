class CreateTriggers < ActiveRecord::Migration[5.2]
  def change
    create_table :triggers do |t|
      t.integer :touchpoint_id
      t.string :name
      t.string :kind
      t.string :fingerprint

      t.timestamps
    end
  end
end
