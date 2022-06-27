class FormsUiTruncateTextResponses < ActiveRecord::Migration[6.1]
  def change
    add_column :forms, :ui_truncate_text_responses, :boolean, default: true

    Form.all.each do |form|
      form.update(ui_truncate_text_responses: true)
    end
  end
end
