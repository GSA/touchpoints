class AddFormFields < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :question_text_01, :text
    add_column :forms, :question_text_02, :text
    add_column :forms, :question_text_03, :text
    add_column :forms, :question_text_04, :text
    add_column :forms, :question_text_05, :text
    add_column :forms, :question_text_06, :text
    add_column :forms, :question_text_07, :text
    add_column :forms, :question_text_08, :text
    add_column :forms, :question_text_09, :text
    add_column :forms, :question_text_10, :text
    add_column :forms, :question_text_11, :text
    add_column :forms, :question_text_12, :text
    add_column :forms, :question_text_13, :text
    add_column :forms, :question_text_14, :text
    add_column :forms, :question_text_15, :text
    add_column :forms, :question_text_16, :text
    add_column :forms, :question_text_17, :text
    add_column :forms, :question_text_18, :text
    add_column :forms, :question_text_19, :text
    add_column :forms, :question_text_20, :text

    add_column :submissions, :answer_01, :text
    add_column :submissions, :answer_02, :text
    add_column :submissions, :answer_03, :text
    add_column :submissions, :answer_04, :text
    add_column :submissions, :answer_05, :text
    add_column :submissions, :answer_06, :text
    add_column :submissions, :answer_07, :text
    add_column :submissions, :answer_08, :text
    add_column :submissions, :answer_09, :text
    add_column :submissions, :answer_10, :text
    add_column :submissions, :answer_11, :text
    add_column :submissions, :answer_12, :text
    add_column :submissions, :answer_13, :text
    add_column :submissions, :answer_14, :text
    add_column :submissions, :answer_15, :text
    add_column :submissions, :answer_16, :text
    add_column :submissions, :answer_17, :text
    add_column :submissions, :answer_18, :text
    add_column :submissions, :answer_19, :text
    add_column :submissions, :answer_20, :text
  end
end
