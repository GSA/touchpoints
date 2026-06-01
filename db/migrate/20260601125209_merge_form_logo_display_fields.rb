# frozen_string_literal: true

class MergeFormLogoDisplayFields < ActiveRecord::Migration[8.0]
  def up
    # Add the new enum field
    add_column :forms, :header_logo_display, :string, default: 'banner', null: false

    # Migrate existing data
    # Priority: display_header_logo (banner) takes precedence if true
    execute <<-SQL.squish
      UPDATE forms
      SET header_logo_display = CASE
        WHEN display_header_logo = TRUE THEN 'banner'
        WHEN display_header_square_logo = TRUE THEN 'square'
        ELSE 'no_logo'
      END
    SQL

    # Remove old columns
    remove_column :forms, :display_header_logo
    remove_column :forms, :display_header_square_logo
  end

  def down
    # Add back the old boolean columns
    add_column :forms, :display_header_logo, :boolean, default: false
    add_column :forms, :display_header_square_logo, :boolean

    # Migrate data back
    execute <<-SQL.squish
      UPDATE forms
      SET display_header_logo = CASE
        WHEN header_logo_display = 'banner' THEN TRUE
        ELSE FALSE
      END,
      display_header_square_logo = CASE
        WHEN header_logo_display = 'square' THEN TRUE
        ELSE FALSE
      END
    SQL

    # Remove the enum column
    remove_column :forms, :header_logo_display
  end
end
