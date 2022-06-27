class CreateServiceStages < ActiveRecord::Migration[5.2]
  def change
    create_table :service_stages do |t|
      t.string :name
      t.text :description
      t.integer :service_id
      t.text :notes
      t.integer :time
      t.integer :position
      t.integer :total_eligible_population

      t.timestamps
    end
  end
end
