class CreateOmbCxReportingCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :omb_cx_reporting_collections do |t|
      t.integer :collection_id
      t.string :service_provided
      t.text :transaction_point
      t.string :channel
      t.integer :volume_of_customers
      t.integer :volume_of_customers_provided_survey_opportunity
      t.integer :volume_of_respondents
      t.string :omb_control_number
      t.string :federal_register_url
      t.string :q1_text
      t.string :q1_1
      t.string :q1_2
      t.string :q1_3
      t.string :q1_4
      t.string :q1_5
      t.string :q2_text
      t.string :q2_1
      t.string :q2_2
      t.string :q2_3
      t.string :q2_4
      t.string :q2_5
      t.string :q3_text
      t.string :q3_1
      t.string :q3_2
      t.string :q3_3
      t.string :q3_4
      t.string :q3_5
      t.string :q4_text
      t.string :q4_1
      t.string :q4_2
      t.string :q4_3
      t.string :q4_4
      t.string :q4_5
      t.string :q5_text
      t.string :q5_1
      t.string :q5_2
      t.string :q5_3
      t.string :q5_4
      t.string :q5_5
      t.string :q6_text
      t.string :q6_1
      t.string :q6_2
      t.string :q6_3
      t.string :q6_4
      t.string :q6_5
      t.string :q7_text
      t.string :q7_1
      t.string :q7_2
      t.string :q7_3
      t.string :q7_4
      t.string :q7_5
      t.string :q8_text
      t.string :q8_1
      t.string :q8_2
      t.string :q8_3
      t.string :q8_4
      t.string :q8_5
      t.string :q9_text
      t.string :q9_1
      t.string :q9_2
      t.string :q9_3
      t.string :q9_4
      t.string :q9_5
      t.string :q10_text
      t.string :q10_1
      t.string :q10_2
      t.string :q10_3
      t.string :q10_4
      t.string :q10_5
      t.string :q11_text
      t.string :q11_1
      t.string :q11_2
      t.string :q11_3
      t.string :q11_4
      t.string :q11_5

      t.timestamps
    end

    add_index :omb_cx_reporting_collections, :collection_id
  end
end
