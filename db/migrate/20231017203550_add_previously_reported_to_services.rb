class AddPreviouslyReportedToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :previously_reported, :boolean, default: false
    add_column :service_providers, :year_designated, :integer
  end
end
