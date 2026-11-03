# frozen_string_literal: true

class RemoveNextSectionIdFromFormSections < ActiveRecord::Migration[8.1]
  def change
    remove_column :form_sections, :next_section_id, :integer
  end
end
