class AddSubmissionHost < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :hostname, :string
  end
end
