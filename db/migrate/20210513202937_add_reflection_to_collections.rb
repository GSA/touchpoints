class AddReflectionToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :reflection, :string
  end
end
