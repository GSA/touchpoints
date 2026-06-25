# frozen_string_literal: true

class AddLogoAltTextToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :logo_alt_text, :string
  end
end
