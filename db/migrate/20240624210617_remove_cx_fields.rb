class RemoveCxFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :services, :bureau_abbreviation
    remove_column :services, :bureau_id
    remove_column :services, :justification_text
    remove_column :services, :service_abbreviation
    remove_column :services, :where_customers_interact

    remove_column :cx_collections, :reflection
    remove_column :cx_collections, :start_date
    remove_column :cx_collections, :end_date
  end
end
