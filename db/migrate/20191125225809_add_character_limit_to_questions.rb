class AddCharacterLimitToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :character_limit, :integer
  end
end
