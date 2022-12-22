class AddPortfolioManagerToServiceProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :service_providers, :portfolio_manager_email, :string
  end
end
