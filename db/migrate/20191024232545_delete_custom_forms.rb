class DeleteCustomForms < ActiveRecord::Migration[5.2]
  def up
    Form.all.each do |form|
      next if form.kind == "custom"
      next if form.touchpoint && form.touchpoint.submissions.present?

      puts "destroying Touchpoint #{form.touchpoint.id} #{form.touchpoint.name}"
      form.touchpoint.destroy
      puts "destroying Form #{form.id} #{form.name} #{form.title}"
      form.destroy
    end
  end
end
