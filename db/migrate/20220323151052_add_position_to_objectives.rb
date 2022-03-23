class AddPositionToObjectives < ActiveRecord::Migration[7.0]
  def change
    add_column :objectives, :position, :integer, default: 0
  end
end
