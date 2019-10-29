class AddEarlySubmissionToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :early_submission, :boolean, default: false
  end
end
