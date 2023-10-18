class RenameSubmissionTags < ActiveRecord::Migration[7.0]
  def change
    rename_column :submissions, :submission_tags, :tags
  end
end
