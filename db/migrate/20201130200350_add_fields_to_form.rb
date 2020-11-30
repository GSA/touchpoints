class AddFieldsToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :response_count, :integer, default: 0
    add_column :forms, :last_response_created_at, :datetime
  end
end
