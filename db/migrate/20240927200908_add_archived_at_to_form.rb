class AddArchivedAtToForm < ActiveRecord::Migration[7.1]
  def up
    add_column :forms, :archived_at, :datetime

    execute <<-SQL.squish
      WITH most_recent_form_archives AS (
        SELECT max(created_at) AS archived_at, object_uuid
        FROM events
        WHERE events.object_type = 'Form'
        AND events.name = 'form_archived'
        GROUP BY object_uuid
      )
      UPDATE forms
      SET archived_at = most_recent_form_archives.archived_at
      FROM most_recent_form_archives
      WHERE most_recent_form_archives.object_uuid = forms.uuid
    SQL
  end

  def down
    remove_column :forms, :archived_at
  end
end
