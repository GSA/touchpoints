class AddStatusToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :aasm_state, :string, default: :received
    add_column :submissions, :archived, :boolean, default: false
  end
end
