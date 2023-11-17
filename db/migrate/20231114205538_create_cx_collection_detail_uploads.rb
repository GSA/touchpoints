class CreateCxCollectionDetailUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :cx_collection_detail_uploads do |t|
      t.integer :user_id
      t.integer :cx_collection_detail_id
      t.integer :size, comment: "file size of the s3 object"
      t.string :key, comment: "s3 path to the asset"

      t.timestamps
    end
  end
end
