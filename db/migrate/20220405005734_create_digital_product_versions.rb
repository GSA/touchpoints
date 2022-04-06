class CreateDigitalProductVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :digital_product_versions do |t|
      t.references :digital_product
      t.string :store_url
      t.string :platform
      t.string :version_number
      t.date :publish_date
      t.string :description
      t.string :whats_new
      t.string :screenshot_url
      t.string :device
      t.string :language
      t.string :average_rating
      t.integer :number_of_ratings
      t.timestamps
    end
  end
end
