class CreateDigitalServiceAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :digital_service_accounts do |t|
      t.integer :organization_id
      t.integer :user_id
      t.string :service
      t.string :service_url
      t.string :account
      t.string :language
      t.string :status
      t.string :short_description
      t.text :long_description
      t.text :notes
      t.string :tags
      t.datetime :certified_at

      t.timestamps
    end
  end
end
