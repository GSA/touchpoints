 class SafeYAML
  def self.load(string)
    return {} if string.nil?

    YAML.safe_load(
      string,
      permitted_classes: [
        Time,
        Date,
        ActiveSupport::TimeWithZone,
        ActiveSupport::TimeZone
      ],
      aliases: true
    )
  end
end

class VersionsJson < ActiveRecord::Migration[8.0]
  def change
    rename_column :versions, :object, :old_object
    rename_column :versions, :object_changes, :old_object_changes
    add_column :versions, :object, :jsonb
    add_column :versions, :object_changes, :jsonb

    PaperTrail::Version.where.not(old_object: nil).in_batches(of: 500, start: 1) do |batch|
      batch.each do |version|
        version.update_columns(
          object: SafeYAML.load(version.old_object),
          old_object: nil,
          object_changes: SafeYAML.load(version.old_object_changes),
          old_object_changes: nil,
        )
      end
    end
  end
end
