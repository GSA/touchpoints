class AddOrganizationPerformanceUrls < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :performance_url, :string
    add_column :organizations, :strategic_plan_url, :string
    add_column :organizations, :learning_agenda_url, :string
  end
end
