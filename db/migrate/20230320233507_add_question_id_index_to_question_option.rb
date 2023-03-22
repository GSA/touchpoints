class AddQuestionIdIndexToQuestionOption < ActiveRecord::Migration[7.0]
  def change
    add_index :question_options, :question_id
    add_index :services, :organization_id
    add_index :form_sections, :form_id
    add_index :goals, :organization_id
    add_index :objectives, :organization_id
    add_index :objectives, :goal_id
    add_index :questions, :form_section_id
    add_index :service_providers, :organization_id
    add_index :service_stages, :service_id
    add_index :submissions, :flagged
  end
end
