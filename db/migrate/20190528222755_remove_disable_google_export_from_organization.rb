class RemoveDisableGoogleExportFromOrganization < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :disable_google_export
  end
end
