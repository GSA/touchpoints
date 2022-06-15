# frozen_string_literal: true

class AddValueToQuestionOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :question_options, :value, :string
  end
end
