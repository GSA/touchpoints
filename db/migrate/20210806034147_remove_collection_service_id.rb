class RemoveCollectionServiceId < ActiveRecord::Migration[6.1]
  def change
    remove_column :collections, :service_id
  end
end
