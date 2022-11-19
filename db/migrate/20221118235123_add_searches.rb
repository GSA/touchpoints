class AddSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :registry_searches do |t|
      t.string :agency
      t.string :keywords
      t.string :platform
      t.string :status
      t.string :session_id

      t.timestamps
    end
  end
end
