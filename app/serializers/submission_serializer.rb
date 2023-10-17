# frozen_string_literal: true

class SubmissionSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :created_at,
             :updated_at,
             :referer,
             :hostname,
             :page,
             :user_agent,
             :answer_01,
             :answer_02,
             :answer_03,
             :answer_04,
             :answer_05,
             :answer_06,
             :answer_07,
             :answer_08,
             :answer_09,
             :answer_10,
             :answer_11,
             :answer_12,
             :answer_13,
             :answer_14,
             :answer_15,
             :answer_16,
             :answer_17,
             :answer_18,
             :answer_19,
             :answer_20,
             :ip_address,
             :location_code,
             :flagged,
             :archived,
             :aasm_state,
             :language,
             :uuid,
             :tag_list

  # override tag_list provided by acts-as-taggable
  # but keep an array of tags
  def tag_list
    object.submission_tags
  end
end
