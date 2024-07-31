class CxCollectionDetailSerializer < ActiveModel::Serializer
  attributes :id,
    :cx_collection_id,
    :service_id,
    :service_name,
    :service_provider_id,
    :service_provider_name,
    :channel,
    :service_stage_id,
    :service_stage_name,
    :volume_of_customers,
    :volume_of_customers_provided_survey_opportunity,
    :volume_of_respondents,
    :omb_control_number,
    :survey_type,
    :survey_title,
    :trust_question_text,
    :created_at,
    :updated_at

    def service_name
      object.service.name if object.service
    end

    def service_stage_name
      object.service_stage.name if object.service_stage
    end

    def service_provider_name
      object.service.service_provider.name if object.service
    end
end
