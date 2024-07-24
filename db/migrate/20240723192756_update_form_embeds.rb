class UpdateFormEmbeds < ActiveRecord::Migration[7.1]
  def change
    Form.update_all(legacy_form_embed: false)
  end
end
