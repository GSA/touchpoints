class AddHelpTextToQuestion < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :help_text, :string
  end
end
