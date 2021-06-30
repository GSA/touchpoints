class AddCollectionServiceId < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :service_id, :integer
  end
end
