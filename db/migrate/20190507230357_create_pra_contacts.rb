class CreatePraContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :pra_contacts do |t|
      t.string :email
      t.string :name
      t.string :department
      t.string :program
      t.integer :organization_id
      t.integer :program_id

      t.timestamps
    end
  end
end
