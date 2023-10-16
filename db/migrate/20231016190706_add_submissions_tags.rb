class AddSubmissionsTags < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :submission_tags, :string, array: true, default: []

    Submission.in_batches do |group|
        group.each do |submission|
            unless tags = submission.tag_list
              submission.update(submission_tags: tags)
            end
        end; nil
    end; nil

  end
end
