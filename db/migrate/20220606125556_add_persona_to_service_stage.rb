class AddPersonaToServiceStage < ActiveRecord::Migration[7.0]
  def change
    add_column :service_stages, :persona_id, :integer
  end
end
