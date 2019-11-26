class RemovePraContactsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :pra_contacts
  end
end
