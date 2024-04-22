# frozen_string_literal: true

class CxResponseSerializer < ActiveModel::Serializer
  attributes :cx_collection_detail_id,
    :cx_collection_detail_upload_id,
    :question_1,
    :positive_effectiveness,
    :positive_ease,
    :positive_efficiency,
    :positive_transparency,
    :positive_humanity,
    :positive_employee,
    :positive_other,
    :negative_effectiveness,
    :negative_ease,
    :negative_efficiency,
    :negative_transparency,
    :negative_humanity,
    :negative_employee,
    :negative_other,
    :question_4,
    :job_id,
    :created_at,
    :updated_at,
    :external_id

end
