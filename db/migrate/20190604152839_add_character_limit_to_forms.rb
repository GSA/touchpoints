class AddCharacterLimitToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :character_limit, :integer, default: 0
  end
end
