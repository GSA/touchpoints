class AddSubmissionsTags < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :submission_tags, :string, array: true, default: []
  end
end
