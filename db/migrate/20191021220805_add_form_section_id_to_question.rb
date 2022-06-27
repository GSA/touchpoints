class AddFormSectionIdToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :form_section_id, :integer

    Form.all.each do |form|
      if form.form_sections.empty?
        new_form_section = FormSection.create!({
          form_id: form.id,
          position: 1
        })
        form.questions.update_all(form_section_id: new_form_section.id)
      end
    end
  end
end
