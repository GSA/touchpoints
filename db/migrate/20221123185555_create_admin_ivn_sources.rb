class CreateAdminIvnSources < ActiveRecord::Migration[7.0]
  def change
    create_table :ivn_sources do |t|
      t.string :name
      t.text :description
      t.string :url
      t.integer :organization_id

      t.timestamps
    end
  end
end
