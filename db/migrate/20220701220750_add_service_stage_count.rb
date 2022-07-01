class AddServiceStageCount < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :service_stage_count, :integer, default: 0

    Service.all.each do |service|
      Service.reset_counters(service.id, :service_stages)
    end
  end
end
