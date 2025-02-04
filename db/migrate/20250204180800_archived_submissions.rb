class ArchivedSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :archived, :boolean, default: false

    Submission.where(aasm_state: :archived).update_all(archived: true, aasm_state: :received)
  end
end
