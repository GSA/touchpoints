class RemoveCxCollectionDetailServiceId < ActiveRecord::Migration[7.1]
  def change
    remove_column :cx_collection_details, :service_id
  end
end
