class RemoveFormCharacterLimit < ActiveRecord::Migration[5.2]
  def change
    remove_column :forms, :character_limit
  end
end
