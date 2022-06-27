class AddServiceToWebsite < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :service_id, :integer
    add_index :websites, :service_id

    add_index :collections, :user_id
    add_index :collections, :organization_id
    add_index :collections, :service_provider_id

    add_index :omb_cx_reporting_collections, :service_id

    add_index :questions, :form_id

    add_index :forms, :user_id
    add_index :forms, :organization_id

    add_index :submissions, :form_id
  end
end
