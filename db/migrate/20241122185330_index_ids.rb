class IndexIds < ActiveRecord::Migration[7.2]
  def change
    add_index :cx_action_plans, :id
    add_index :cx_collection_details, :id
    add_index :cx_collections, :id
    add_index :cx_responses, :id
    add_index :digital_products, :id
    add_index :digital_service_accounts, :id
    add_index :forms, :id
    add_index :organizations, :id
    add_index :personas, :id
    add_index :service_providers, :id
    add_index :services, :id
    add_index :service_stages, :id
    add_index :submissions, :id
    add_index :users, :id
    add_index :websites, :id
  end
end
