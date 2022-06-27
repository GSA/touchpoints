class CreateDigitalProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :digital_products do |t|
      t.integer :organization_id
      t.integer :user_id
      t.string :service
      t.string :url
      t.string :code_repository_url
      t.string :language
      t.string :status
      t.string :aasm_status
      t.string :short_description
      t.text :long_description
      t.text :notes
      t.string :tags
      t.datetime :certified_at

      t.timestamps
    end
  end
end
