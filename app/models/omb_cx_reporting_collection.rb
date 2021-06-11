class OmbCxReportingCollection < ApplicationRecord
  belongs_to :collection

  validates :service_provided, presence: true

  def answer_points(question: :q1)
    self.send("#{question}_1") * 1.0 +
    self.send("#{question}_2") * 2.0 +
    self.send("#{question}_3") * 3.0 +
    self.send("#{question}_4") * 4.0 +
    self.send("#{question}_5") * 5.0
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
    self.send("#{question}_1") +
    self.send("#{question}_2") +
    self.send("#{question}_3") +
    self.send("#{question}_4") +
    self.send("#{question}_5")
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
    self.q1_total + self.q2_total + self.q3_total + self.q4_total + self.q5_total + self.q6_total + self.q7_total + self.q8_total + self.q9_total + self.q10_total + self.q11_total
  end
end
