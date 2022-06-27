class CreateFormSections < ActiveRecord::Migration[5.2]
  def change
    create_table :form_sections do |t|
      t.integer :form_id
      t.string :title
      t.integer :position
      t.integer :next_section_id

      t.timestamps
    end
  end
end
