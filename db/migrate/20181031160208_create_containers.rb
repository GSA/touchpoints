class CreateContainers < ActiveRecord::Migration[5.2]
  def change
    create_table :containers do |t|
      t.string :name
      t.string :gtm_container_id
      t.string :gtm_container_public_id

      t.timestamps
    end
  end
end
