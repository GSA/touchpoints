class CacheSubmissionPreview < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :preview, :string, default: ""
  end
end
