class AddCxReportingFieldsToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :medium, :string
    add_column :touchpoints, :federal_register_url, :string
    add_column :touchpoints, :anticipated_delivery_count, :integer, default: 0
    add_column :touchpoints, :survey_form_activations, :integer, default: 0
  end
end
