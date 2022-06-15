# frozen_string_literal: true

class AddPlaceholderTextToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :placeholder_text, :string
  end
end
