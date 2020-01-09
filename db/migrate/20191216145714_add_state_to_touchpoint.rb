class AddStateToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :aasm_state, :string
  end
end
