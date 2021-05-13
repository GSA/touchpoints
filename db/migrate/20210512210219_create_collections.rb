class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :collections do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :organization_id
      t.string :year
      t.string :quarter
      t.integer :user_id
      t.string :integrity_hash
      t.string :aasm_state

      t.timestamps
    end
  end
end
