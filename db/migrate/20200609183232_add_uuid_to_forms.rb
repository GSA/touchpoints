class AddUuidToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :uuid, :string
    add_index :submissions, :uuid, unique: true

    Submission.all.each do |submission|
      submission.set_uuid
      submission.save!
    end
  end
end
