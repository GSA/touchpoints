class AddPraReportingFields < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :service_name, :string
    add_column :touchpoints, :data_submission_comment, :text
    add_column :touchpoints, :survey_instrument_reference, :string
    add_column :touchpoints, :agency_poc_email, :string
    add_column :touchpoints, :agency_poc_name, :string
    add_column :touchpoints, :department, :string
    add_column :touchpoints, :bureau, :string
  end
end
