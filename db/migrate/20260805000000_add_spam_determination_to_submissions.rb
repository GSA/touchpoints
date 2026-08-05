# frozen_string_literal: true

class AddSpamDeterminationToSubmissions < ActiveRecord::Migration[8.1]
  def up
    add_column :submissions, :spam_determination, :jsonb,
               comment: "Provenance of a spam determination: which source (manual/automated) " \
                        "and, for automated, which checks fired. Never contains free-text detail."

    # All submissions currently marked as spam were marked manually, so
    # backfill their provenance accordingly. Non-spam rows remain null.
    execute(<<~SQL.squish)
      UPDATE submissions
      SET spam_determination = '{"source":"manual"}'::jsonb
      WHERE spam = true
    SQL
  end

  def down
    remove_column :submissions, :spam_determination
  end
end
