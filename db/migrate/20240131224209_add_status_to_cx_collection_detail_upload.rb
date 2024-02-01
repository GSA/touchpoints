class AddStatusToCxCollectionDetailUpload < ActiveRecord::Migration[7.1]
  def change
    add_column :cx_collection_detail_uploads, :aasm_state, :string
    add_column :cx_collection_detail_uploads, :record_count, :string
    add_column :cx_collection_detail_uploads, :job_id, :string
  end
end
