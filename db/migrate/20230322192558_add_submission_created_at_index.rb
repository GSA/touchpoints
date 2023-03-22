class AddSubmissionCreatedAtIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :submissions, :created_at
    add_column :forms, :submissions_tags, :string, array: true
  end
end
