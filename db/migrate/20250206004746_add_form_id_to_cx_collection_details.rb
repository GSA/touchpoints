class AddFormIdToCxCollectionDetails < ActiveRecord::Migration[7.2]
  def change
    add_column :cx_collection_details, :form_id, :string
  end
end
