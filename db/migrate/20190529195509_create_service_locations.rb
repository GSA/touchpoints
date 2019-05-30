class CreateServiceLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :service_locations do |t|
      t.string :name
      t.string :abbreviation
      t.integer :organization_id

      t.timestamps
    end
  end
end
