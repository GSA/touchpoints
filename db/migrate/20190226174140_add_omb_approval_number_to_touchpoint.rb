class AddOmbApprovalNumberToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :omb_approval_number, :string
  end
end
