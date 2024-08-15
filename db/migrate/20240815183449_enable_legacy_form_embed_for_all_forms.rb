# frozen_string_literal: true

# Feature flag migration to accompany release of USWDS-based modal
class EnableLegacyFormEmbedForAllForms < ActiveRecord::Migration[7.1]
  def up
    execute 'UPDATE forms SET legacy_form_embed = TRUE'
  end

  def down
    execute 'UPDATE forms SET legacy_form_embed = FALSE'
  end
end
