class ChangeObjectId < ActiveRecord::Migration[7.1]
  def change
    rename_column :events, :object_id, :object_uuid
  end
end
