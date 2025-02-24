class CacheSubmissionPreview < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :preview, :string, default: ""

    Submission.unscoped.in_batches(of: 10_000) do |batch|
      batch.each do |submission|
        submission.set_preview
      end
    end
  end
end
