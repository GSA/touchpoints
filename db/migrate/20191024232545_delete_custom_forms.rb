class DeleteCustomForms < ActiveRecord::Migration[5.2]
  def up
    Form.all.each do |form|
      next if form.kind == "custom"
      next if form.touchpoint && form.touchpoint.submissions.present?

      if form.touchpoint
        puts "destroying Touchpoint #{form.touchpoint.id} #{form.touchpoint.name}"
        form.touchpoint.destroy
      end
      puts "destroying Form #{form.id} #{form.name} #{form.title}"
      form.destroy
    end
  end
end
