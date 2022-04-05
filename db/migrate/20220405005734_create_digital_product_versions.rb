class CreateDigitalProductVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :digital_product_versions do |t|
      t.references :digital_product
      t.string :store_url
      t.timestamps
    end
  end
end
