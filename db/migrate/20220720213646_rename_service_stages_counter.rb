class RenameServiceStagesCounter < ActiveRecord::Migration[7.0]
  def change
    rename_column :services, :service_stage_count, :service_stages_count

    Service.all.each do |service|
      Service.reset_counters(service.id, :service_stages)
    end
  end
end
