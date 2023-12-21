class CreateCxResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :cx_responses do |t|
      t.integer :cx_collection_detail_id
      t.integer :cx_collection_detail_upload_id
      t.string :question_1, comment: "thumbs up/down"
      t.string :positive_effectiveness
      t.string :positive_ease
      t.string :positive_efficiency
      t.string :positive_transparency
      t.string :positive_humanity
      t.string :positive_employee
      t.string :positive_other
      t.string :negative_effectiveness
      t.string :negative_ease
      t.string :negative_efficiency
      t.string :negative_transparency
      t.string :negative_humanity
      t.string :negative_employee
      t.string :negative_other
      t.string :question_4, comment: "open text"
      t.string :job_id, comment: "a unique ID assigned when a batch of responses is imported"

      t.timestamps
    end
  end
end
