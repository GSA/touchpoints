class OtherQuestionOption < ActiveRecord::Migration[7.2]
  def change
    add_column :question_options, :other_option, :boolean, default: false

    QuestionOption.all.each do |option|
      if ["OTHER", "OTRO"].include?(option.text.upcase)
        option.update(other_option: true)
      end
    end
  end
end
