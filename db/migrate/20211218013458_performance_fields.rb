class PerformanceFields < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :mission_statement, :text
    add_column :organizations, :mission_statement_url, :string

    add_column :service_providers, :url, :string

    add_column :services, :service_owner_id, :integer

    add_column :goals, :four_year_goal, :boolean, default: false
    add_column :goals, :parent_id, :integer
    add_column :goals, :position, :integer
  end
end
