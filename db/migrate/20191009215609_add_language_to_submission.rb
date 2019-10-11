class AddLanguageToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :language, :string

    Submission.update_all(language: "en")
  end
end
