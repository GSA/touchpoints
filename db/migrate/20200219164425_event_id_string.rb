class EventIdString < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :object_id, :string, null: false
  end
end
