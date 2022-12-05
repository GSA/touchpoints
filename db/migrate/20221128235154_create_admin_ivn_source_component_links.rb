class CreateAdminIvnSourceComponentLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :ivn_source_component_links do |t|
      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end
  end
end
