class FormQuestionsCount < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :questions_count, :integer, default: 0

    Form.all.each do |form|
      Form.reset_counters(form.id, :questions)
    end
  end
end
