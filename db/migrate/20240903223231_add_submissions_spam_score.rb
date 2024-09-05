class AddSubmissionsSpamScore < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :spam_score, :integer, default: 0
  end
end
