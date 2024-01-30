# frozen_string_literal: true

class CxResponseSerializer < ActiveModel::Serializer
  attributes :page, :size, :start_date, :end_date

  def page
    @instance_options[:page]
  end

  def size
    @instance_options[:size]
  end

  def start_date
    @instance_options[:start_date]
  end

  def end_date
    @instance_options[:end_date]
  end

  def links
    @instance_options[:links]
  end

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
