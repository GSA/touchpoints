class CxResponse < ApplicationRecord
  belongs_to :cx_collection_detail
  belongs_to :cx_collection_detail_upload

  max_paginates_per(5000)

  def self.to_csv
    responses = CxResponse.all

    attributes = %i[
      cx_collection_detail_id
      cx_collection_detail_upload_id
      question_1
      positive_effectiveness
      positive_ease
      positive_efficiency
      positive_transparency
      positive_humanity
      positive_employee
      positive_other
      negative_effectiveness
      negative_ease
      negative_efficiency
      negative_transparency
      negative_humanity
      negative_employee
      negative_other
      question_4
      job_id
      external_id
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      responses.each do |response|
        csv << attributes = [
          response.cx_collection_detail_id,
          response.cx_collection_detail_upload_id,
          response.question_1,
          response.positive_effectiveness,
          response.positive_ease,
          response.positive_efficiency,
          response.positive_transparency,
          response.positive_humanity,
          response.positive_employee,
          response.positive_other,
          response.negative_effectiveness,
          response.negative_ease,
          response.negative_efficiency,
          response.negative_transparency,
          response.negative_humanity,
          response.negative_employee,
          response.negative_other,
          response.question_4,
          response.job_id,
          response.external_id,
        ]
      end
    end
  end
end
