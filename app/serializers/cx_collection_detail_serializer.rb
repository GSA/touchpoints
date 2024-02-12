class CxCollectionDetailSerializer < ActiveModel::Serializer
  attributes :id,
    :cx_collection_id,
    :service_id,
    :transaction_point,
    :channel,
    :service_stage_id,
    :service_stage_name,
    :volume_of_customers,
    :volume_of_customers_provided_survey_opportunity,
    :volume_of_respondents,
    :omb_control_number,
    :federal_register_url,
    :reflection_text,
    :survey_type,
    :survey_title,
    :trust_question_text

    def service_stage_name
      object.service_stage.name if object.service_stage
    end
end
