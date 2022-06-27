class RemoveUswdsScore < ActiveRecord::Migration[6.1]
  def change
    remove_column :websites, :current_uswds_score, :integer
    remove_column :websites, :parent_domain, :string
  end
end
