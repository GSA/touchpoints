class RemoveProgramsAndFormTemplates < ActiveRecord::Migration[5.2]
  def change
    drop_table :programs
    drop_table :form_templates
  end
end
