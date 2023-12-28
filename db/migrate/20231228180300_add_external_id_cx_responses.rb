class AddExternalIdCxResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :cx_responses, :external_id, :string
  end
end
