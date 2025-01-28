class AddSpamToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :spam, :boolean, default: false

    Submission.update_all(spam: false)
  end
end
