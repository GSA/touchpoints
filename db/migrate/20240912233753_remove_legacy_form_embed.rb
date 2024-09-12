class RemoveLegacyFormEmbed < ActiveRecord::Migration[7.1]
  def change
    remove_column :forms, :legacy_form_embed
  end
end
