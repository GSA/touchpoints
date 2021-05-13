class CreateBarriers < ActiveRecord::Migration[5.2]
  def change
    create_table :barriers do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
