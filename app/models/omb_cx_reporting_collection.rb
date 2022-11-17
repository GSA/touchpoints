# frozen_string_literal: true

class OmbCxReportingCollection < ApplicationRecord
  belongs_to :collection
  belongs_to :service

  validates :service_provided, presence: true

  scope :published, lambda {
    joins(:collection).where("collections.aasm_state = 'published'")
  }

  (1..11).each do |q|
    (1..5).each do |a|
      validates_numericality_of "q#{q}_#{a}".to_sym
    end
  end

  def answer_points(question:)
    (send("#{question}_1") * 1.0) +
      (send("#{question}_2") * 2.0) +
      (send("#{question}_3") * 3.0) +
      (send("#{question}_4") * 4.0) +
      (send("#{question}_5") * 5.0)
  end

  def omb_control_number
    super || 'OMB Control Number'
  end

  def federal_register_url
    super || 'Federal Register URL'
  end

  def q1_point_scale
    (
      answer_points(question: :q1) /
      q1_total
    ).round(2)
  end

  def q2_point_scale
    (
      answer_points(question: :q2) /
      q2_total
    ).round(2)
  end

  def q3_point_scale
    (
      answer_points(question: :q3) /
      q3_total
    ).round(2)
  end

  def q4_point_scale
    (
      answer_points(question: :q4) /
      q4_total
    ).round(2)
  end

  def q5_point_scale
    (
      answer_points(question: :q5) /
      q5_total
    ).round(2)
  end

  def q6_point_scale
    (
      answer_points(question: :q6) /
      q6_total
    ).round(2)
  end

  def q7_point_scale
    (
      answer_points(question: :q7) /
      q7_total
    ).round(2)
  end

  def q8_point_scale
    (
      answer_points(question: :q8) /
      q8_total
    ).round(2)
  end

  def q9_point_scale
    (
      answer_points(question: :q9) /
      q9_total
    ).round(2)
  end

  def q10_point_scale
    (
      answer_points(question: :q10) /
      q10_total
    ).round(2)
  end

  def q11_point_scale
    (
      answer_points(question: :q11) /
      q11_total
    ).round(2)
  end

  def question_total(question: nil)
    send("#{question}_1") +
      send("#{question}_2") +
      send("#{question}_3") +
      send("#{question}_4") +
      send("#{question}_5")
  end

  def q1_total
    question_total(question: :q1)
  end

  def q2_total
    question_total(question: :q2)
  end

  def q3_total
    question_total(question: :q3)
  end

  def q4_total
    question_total(question: :q4)
  end

  def q5_total
    question_total(question: :q5)
  end

  def q6_total
    question_total(question: :q6)
  end

  def q7_total
    question_total(question: :q7)
  end

  def q8_total
    question_total(question: :q8)
  end

  def q9_total
    question_total(question: :q9)
  end

  def q10_total
    question_total(question: :q10)
  end

  def q11_total
    question_total(question: :q11)
  end

  def volume_total
    q1_total + q2_total + q3_total + q4_total + q5_total + q6_total + q7_total + q8_total + q9_total + q10_total + q11_total
  end

  def self.to_csv
    omb_cx_reporting_collections = OmbCxReportingCollection.all

    attributes = %i[
      id
      collection_id
      collection_name
      collection_organization_id
      collection_organization_name
      service_provided
      service_id
      service_name
      transaction_point
      channel
      volume_of_customers
      volume_of_customers_provided_survey_opportunity
      volume_of_respondents
      omb_control_number
      federal_register_url
      q1_text
      q1_1
      q1_2
      q1_3
      q1_4
      q1_5
      q2_text
      q2_1
      q2_2
      q2_3
      q2_4
      q2_5
      q3_text
      q3_1
      q3_2
      q3_3
      q3_4
      q3_5
      q4_text
      q4_1
      q4_2
      q4_3
      q4_4
      q4_5
      q5_text
      q5_1
      q5_2
      q5_3
      q5_4
      q5_5
      q6_text
      q6_1
      q6_2
      q6_3
      q6_4
      q6_5
      q7_text
      q7_1
      q7_2
      q7_3
      q7_4
      q7_5
      q8_text
      q8_1
      q8_2
      q8_3
      q8_4
      q8_5
      q9_text
      q9_1
      q9_2
      q9_3
      q9_4
      q9_5
      q10_text
      q10_1
      q10_2
      q10_3
      q10_4
      q10_5
      q11_text
      q11_1
      q11_2
      q11_3
      q11_4
      q11_5
      created_at
      updated_at
      operational_metrics
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
        csv << attributes = [
          omb_cx_reporting_collection.id,
          omb_cx_reporting_collection.collection_id,
          omb_cx_reporting_collection.collection.name,
          omb_cx_reporting_collection.collection.organization_id,
          omb_cx_reporting_collection.collection.organization.name,
          omb_cx_reporting_collection.service_provided,
          omb_cx_reporting_collection.service_id,
          omb_cx_reporting_collection.service.name,
          omb_cx_reporting_collection.transaction_point,
          omb_cx_reporting_collection.channel,
          omb_cx_reporting_collection.volume_of_customers,
          omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity,
          omb_cx_reporting_collection.volume_of_respondents,
          omb_cx_reporting_collection.omb_control_number,
          omb_cx_reporting_collection.federal_register_url,
          omb_cx_reporting_collection.q1_text,
          omb_cx_reporting_collection.q1_1,
          omb_cx_reporting_collection.q1_2,
          omb_cx_reporting_collection.q1_3,
          omb_cx_reporting_collection.q1_4,
          omb_cx_reporting_collection.q1_5,
          omb_cx_reporting_collection.q2_text,
          omb_cx_reporting_collection.q2_1,
          omb_cx_reporting_collection.q2_2,
          omb_cx_reporting_collection.q2_3,
          omb_cx_reporting_collection.q2_4,
          omb_cx_reporting_collection.q2_5,
          omb_cx_reporting_collection.q3_text,
          omb_cx_reporting_collection.q3_1,
          omb_cx_reporting_collection.q3_2,
          omb_cx_reporting_collection.q3_3,
          omb_cx_reporting_collection.q3_4,
          omb_cx_reporting_collection.q3_5,
          omb_cx_reporting_collection.q4_text,
          omb_cx_reporting_collection.q4_1,
          omb_cx_reporting_collection.q4_2,
          omb_cx_reporting_collection.q4_3,
          omb_cx_reporting_collection.q4_4,
          omb_cx_reporting_collection.q4_5,
          omb_cx_reporting_collection.q5_text,
          omb_cx_reporting_collection.q5_1,
          omb_cx_reporting_collection.q5_2,
          omb_cx_reporting_collection.q5_3,
          omb_cx_reporting_collection.q5_4,
          omb_cx_reporting_collection.q5_5,
          omb_cx_reporting_collection.q6_text,
          omb_cx_reporting_collection.q6_1,
          omb_cx_reporting_collection.q6_2,
          omb_cx_reporting_collection.q6_3,
          omb_cx_reporting_collection.q6_4,
          omb_cx_reporting_collection.q6_5,
          omb_cx_reporting_collection.q7_text,
          omb_cx_reporting_collection.q7_1,
          omb_cx_reporting_collection.q7_2,
          omb_cx_reporting_collection.q7_3,
          omb_cx_reporting_collection.q7_4,
          omb_cx_reporting_collection.q7_5,
          omb_cx_reporting_collection.q8_text,
          omb_cx_reporting_collection.q8_1,
          omb_cx_reporting_collection.q8_2,
          omb_cx_reporting_collection.q8_3,
          omb_cx_reporting_collection.q8_4,
          omb_cx_reporting_collection.q8_5,
          omb_cx_reporting_collection.q9_text,
          omb_cx_reporting_collection.q9_1,
          omb_cx_reporting_collection.q9_2,
          omb_cx_reporting_collection.q9_3,
          omb_cx_reporting_collection.q9_4,
          omb_cx_reporting_collection.q9_5,
          omb_cx_reporting_collection.q10_text,
          omb_cx_reporting_collection.q10_1,
          omb_cx_reporting_collection.q10_2,
          omb_cx_reporting_collection.q10_3,
          omb_cx_reporting_collection.q10_4,
          omb_cx_reporting_collection.q10_5,
          omb_cx_reporting_collection.q11_text,
          omb_cx_reporting_collection.q11_1,
          omb_cx_reporting_collection.q11_2,
          omb_cx_reporting_collection.q11_3,
          omb_cx_reporting_collection.q11_4,
          omb_cx_reporting_collection.q11_5,
          omb_cx_reporting_collection.created_at,
          omb_cx_reporting_collection.updated_at,
          omb_cx_reporting_collection.operational_metrics,
        ]
      end
    end
  end

  delegate :organization, to: :collection

  delegate :id, to: :organization, prefix: true

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true

  delegate :name, to: :collection, prefix: true

  delegate :year, to: :collection, prefix: true

  delegate :quarter, to: :collection, prefix: true

  delegate :name, to: :service, prefix: true

  delegate :service_slug, to: :service
end
