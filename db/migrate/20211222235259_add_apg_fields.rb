class AddApgFields < ActiveRecord::Migration[6.1]
  def change
    add_column :goals, :goal_statement, :text
    add_column :goals, :challenge, :text
    add_column :goals, :opportunity, :text
    add_column :goals, :notes, :text
  end
end
