class RemoveFormEarlySubmission < ActiveRecord::Migration[7.2]
  def change
    remove_column :forms, :early_submission
  end
end
