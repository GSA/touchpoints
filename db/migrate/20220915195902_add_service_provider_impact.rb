class AddServiceProviderImpact < ActiveRecord::Migration[7.0]
  def change
    add_column :service_providers, :impact_mapping_value, :integer, default: 0
    add_column :services, :potential_solutions_for_digitization, :string
    add_column :goals, :objectives_count, :integer, default: 0

    Goal.all.each do |goal|
      Goal.reset_counters(goal.id, :objectives)
    end
  end
end
