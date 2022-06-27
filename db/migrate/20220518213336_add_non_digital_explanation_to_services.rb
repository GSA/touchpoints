class AddNonDigitalExplanationToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :non_digital_explanation, :text
  end
end
