class AddStatusToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :aasm_state, :string, default: :received

    Submission.all.each do |submission|
      submission.update(aasm_state: :received)
    end
  end
end
