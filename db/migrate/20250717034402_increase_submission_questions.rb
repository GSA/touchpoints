class IncreaseSubmissionQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :answer_21, :text
    add_column :submissions, :answer_22, :text
    add_column :submissions, :answer_23, :text
    add_column :submissions, :answer_24, :text
    add_column :submissions, :answer_25, :text
    add_column :submissions, :answer_26, :text
    add_column :submissions, :answer_27, :text
    add_column :submissions, :answer_28, :text
    add_column :submissions, :answer_29, :text
    add_column :submissions, :answer_30, :text
  end
end
