# frozen_string_literal: true

class OmbCxReportingCollection < ApplicationRecord
  belongs_to :collection
  belongs_to :service

  validates :service_provided, presence: true

  scope :published, -> { 
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
