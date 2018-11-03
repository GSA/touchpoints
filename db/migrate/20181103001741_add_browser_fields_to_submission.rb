class AddBrowserFieldsToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :referer, :string
    add_column :submissions, :page, :string
    add_column :submissions, :user_agent, :string
  end
end
