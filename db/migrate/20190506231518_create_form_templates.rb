class CreateFormTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :form_templates do |t|
      t.string :name
      t.string :title
      t.string :instructions
      t.text :disclaimer_text
      t.string :kind
      t.text :notes
      t.string :status

      t.timestamps
    end
  end
end
