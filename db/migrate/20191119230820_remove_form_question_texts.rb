class RemoveFormQuestionTexts < ActiveRecord::Migration[5.2]
  def change
    remove_column :forms, :question_text_01
    remove_column :forms, :question_text_02
    remove_column :forms, :question_text_03
    remove_column :forms, :question_text_04
    remove_column :forms, :question_text_05
    remove_column :forms, :question_text_06
    remove_column :forms, :question_text_07
    remove_column :forms, :question_text_08
    remove_column :forms, :question_text_09
    remove_column :forms, :question_text_10
    remove_column :forms, :question_text_11
    remove_column :forms, :question_text_12
    remove_column :forms, :question_text_13
    remove_column :forms, :question_text_14
    remove_column :forms, :question_text_15
    remove_column :forms, :question_text_16
    remove_column :forms, :question_text_17
    remove_column :forms, :question_text_18
    remove_column :forms, :question_text_19
    remove_column :forms, :question_text_20
  end
end
