class AddWebsiteAasmState < ActiveRecord::Migration[7.0]
  def change
    add_column :websites, :aasm_state, :string
    add_index :websites, :aasm_state
  end
end
