class SubmissionArchiveStatus < ActiveRecord::Migration[7.0]
  def change
    Submission.where(archived: true).update_all(aasm_state: :archived)

    remove_column :submissions, :archived
  end
end
