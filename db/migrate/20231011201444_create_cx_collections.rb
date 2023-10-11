class CreateCxCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :cx_collections do |t|
      t.integer :user_id
      t.string :name
      t.integer :organization_id
      t.integer :service_provider_id
      t.integer :service_id
      t.string :service_type
      t.string :digital_service_or_contact_center
      t.string :url
      t.string :fiscal_year
      t.string :quarter
      t.date :start_date
      t.date :end_date
      t.string :transaction_point
      t.integer :service_stage_id
      t.string :channel
      t.string :survey_title
      t.string :trust_question_text
      t.string :likert_or_thumb_question
      t.integer :number_of_interactions
      t.string :number_of_people_offered_the_survey
      t.text :reflection
      t.string :aasm_state
      t.string :rating
      t.string :integrity_hash

      t.timestamps
    end
  end
end
