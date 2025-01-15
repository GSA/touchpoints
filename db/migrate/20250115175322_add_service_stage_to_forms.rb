class AddServiceStageToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :service_stage_id, :integer, default: nil
  end
end
