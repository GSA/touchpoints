class CreateCxCollectionDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :cx_collection_details do |t|
      t.integer :cx_collection_id
      t.integer :service_id
      t.string :transaction_point
      t.string :channel
      t.integer :service_stage_id
      t.integer :volume_of_customers
      t.integer :volume_of_customers_provided_survey_opportunity
      t.integer :volume_of_respondents
      t.string :omb_control_number
      t.integer :federal_register_url
      t.text :reflection_text
      t.text :survey_type
      t.text :survey_title
      t.text :trust_question_text

      t.timestamps
    end
  end
end
