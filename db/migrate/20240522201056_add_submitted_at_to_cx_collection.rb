class AddSubmittedAtToCxCollection < ActiveRecord::Migration[7.1]
  def change
    add_column :cx_collections, :submitted_at, :datetime
  end
end
