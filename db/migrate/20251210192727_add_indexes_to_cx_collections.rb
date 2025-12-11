class AddIndexesToCxCollections < ActiveRecord::Migration[8.0]
  def change
    # cx_collections table - missing all FK indexes
    add_index :cx_collections, :organization_id
    add_index :cx_collections, :user_id
    add_index :cx_collections, :service_provider_id
    add_index :cx_collections, :service_id

    # cx_collection_details table - missing FK index
    add_index :cx_collection_details, :cx_collection_id

    # cx_responses table - missing FK indexes
    add_index :cx_responses, :cx_collection_detail_id
    add_index :cx_responses, :cx_collection_detail_upload_id
  end
end
