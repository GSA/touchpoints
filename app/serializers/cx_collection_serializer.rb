class CxCollectionSerializer < ActiveModel::Serializer
  attributes :id,
    :user_id,
    :name,
    :organization_id,
    :service_provider_id,
    :service_id,
    :service_type,
    :digital_service_or_contact_center,
    :url,
    :fiscal_year,
    :quarter,
    :start_date,
    :end_date,
    :transaction_point,
    :service_stage_id,
    :channel,
    :survey_title,
    :trust_question_text,
    :likert_or_thumb_question,
    :number_of_interactions,
    :number_of_people_offered_the_survey,
    :reflection,
    :aasm_state,
    :rating,
    :integrity_hash

end
