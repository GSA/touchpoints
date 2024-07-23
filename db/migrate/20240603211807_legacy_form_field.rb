class LegacyFormField < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :legacy_form_embed, :boolean, default: false
  end
end
