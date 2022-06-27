class CreateOfferings < ActiveRecord::Migration[7.0]
  def change
    create_table :offerings do |t|
      t.string :name
      t.integer :service_id
      t.timestamps
    end
  end
end
