class AddFormSubmissionTags < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :submission_tags, :string, array: true, comment: "cache the form's submissions tags for reporting"
  end
end
