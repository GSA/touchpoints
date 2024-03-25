class AddFieldsToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :response_count, :integer, default: 0
    add_column :forms, :last_response_created_at, :datetime

    Form.all.each do |form|
      Form.reset_counters(form.id, :submissions)
      form.update(last_response_created_at: form.submissions.last.created_at) if form.submissions.size > 0
    end
  end
end
