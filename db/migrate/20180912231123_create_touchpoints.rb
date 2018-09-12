class CreateTouchpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :touchpoints do |t|
      t.string :name
      t.integer :organization_id
      t.text :purpose
      t.integer :meaningful_response_size
      t.text :behavior_change
      t.string :notification_emails
      t.text :embed_code

      t.timestamps
    end
  end
end
