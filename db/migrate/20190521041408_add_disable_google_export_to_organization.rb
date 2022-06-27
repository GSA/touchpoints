class AddDisableGoogleExportToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :disable_google_export, :boolean, default: false
  end
end
