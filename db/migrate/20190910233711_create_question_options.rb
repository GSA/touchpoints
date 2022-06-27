class CreateQuestionOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :question_options do |t|
      t.integer :question_id
      t.string :text
      t.integer :position

      t.timestamps
    end
  end
end
