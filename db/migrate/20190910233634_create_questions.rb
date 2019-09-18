class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.integer :form_id
      t.string :text
      t.string :question_type
      t.string :answer_field
      t.integer :position
      t.boolean :is_required

      t.timestamps
    end
  end
end
