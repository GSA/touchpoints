class SubmissionDeletedAt < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :deleted, :boolean, default: false
    add_column :submissions, :deleted_at, :datetime

    Submission.update_all(deleted: false)
  end
end
