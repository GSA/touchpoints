class DefaultGoalPosition < ActiveRecord::Migration[7.0]
  def change
    change_column_default :goals, :position, 0
  end
end
