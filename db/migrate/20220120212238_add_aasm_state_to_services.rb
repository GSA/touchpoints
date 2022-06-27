class AddAasmStateToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :aasm_state, :string, default: :created
  end
end
