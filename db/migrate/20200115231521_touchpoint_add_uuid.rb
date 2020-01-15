class TouchpointAddUuid < ActiveRecord::Migration[5.2]
  def change
  	add_column :touchpoints, :uuid, :string
  	add_index :touchpoints, :uuid
  end
end
