class AddIpToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :ip_address, :string
  end
end
