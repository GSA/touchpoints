class AddFormsSubmissionsCount < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :submissions_count, :integer, default: 0

    Form.all.each do |form|
      form.update_attribute(:submissions_count, form.submissions.count)
    end
  end
end
