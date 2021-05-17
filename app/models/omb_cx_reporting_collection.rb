class OmbCxReportingCollection < ApplicationRecord
  belongs_to :collection

  validates :service_provided, presence: true

  def q1_point_scale
    (self.q1_1 * 1.0) +
    (self.q1_2 * 2.0) +
    (self.q1_3 * 3.0) +
    (self.q1_4 * 4.0) +
    (self.q1_5 * 5.0)
  end

  def q2_point_scale
    (self.q2_1 * 1.0) +
    (self.q2_2 * 2.0) +
    (self.q2_3 * 3.0) +
    (self.q2_4 * 4.0) +
    (self.q2_5 * 5.0)
  end

  def q3_point_scale
    (self.q3_1 * 1.0) +
    (self.q3_2 * 2.0) +
    (self.q3_3 * 3.0) +
    (self.q3_4 * 4.0) +
    (self.q3_5 * 5.0)
  end

  def q4_point_scale
    (self.q4_1 * 1.0) +
    (self.q4_2 * 2.0) +
    (self.q4_3 * 3.0) +
    (self.q4_4 * 4.0) +
    (self.q4_5 * 5.0)
  end

  def q5_point_scale
    (self.q5_1 * 1.0) +
    (self.q5_2 * 2.0) +
    (self.q5_3 * 3.0) +
    (self.q5_4 * 4.0) +
    (self.q5_5 * 5.0)
  end

  def q6_point_scale
    (self.q6_1 * 1.0) +
    (self.q6_2 * 2.0) +
    (self.q6_3 * 3.0) +
    (self.q6_4 * 4.0) +
    (self.q6_5 * 5.0)
  end

  def q7_point_scale
    (self.q7_1 * 1.0) +
    (self.q7_2 * 2.0) +
    (self.q7_3 * 3.0) +
    (self.q7_4 * 4.0) +
    (self.q7_5 * 5.0)
  end

  def q8_point_scale
    (self.q8_1 * 1.0) +
    (self.q8_2 * 2.0) +
    (self.q8_3 * 3.0) +
    (self.q8_4 * 4.0) +
    (self.q8_5 * 5.0)
  end

  def q9_point_scale
    (self.q9_1 * 1.0) +
    (self.q9_2 * 2.0) +
    (self.q9_3 * 3.0) +
    (self.q9_4 * 4.0) +
    (self.q9_5 * 5.0)
  end

  def q10_point_scale
    (self.q10_1 * 1.0) +
    (self.q10_2 * 2.0) +
    (self.q10_3 * 3.0) +
    (self.q10_4 * 4.0) +
    (self.q10_5 * 5.0)
  end

  def q11_point_scale
    (self.q11_1 * 1.0) +
    (self.q11_2 * 2.0) +
    (self.q11_3 * 3.0) +
    (self.q11_4 * 4.0) +
    (self.q11_5 * 5.0)
  end


  def q1_total
    self.q1_1 + self.q1_2 + self.q1_3 + self.q1_4 + self.q1_5
  end

  def q2_total
    self.q2_1 + self.q2_2 + self.q2_3 + self.q2_4 + self.q2_5
  end

  def q3_total
    self.q3_1 + self.q3_2 + self.q3_3 + self.q3_4 + self.q3_5
  end

  def q4_total
    self.q4_1 + self.q4_2 + self.q4_3 + self.q4_4 + self.q4_5
  end

  def q5_total
    self.q5_1 + self.q5_2 + self.q5_3 + self.q5_4 + self.q5_5
  end

  def q6_total
    self.q6_1 + self.q6_2 + self.q6_3 + self.q6_4 + self.q6_5
  end

  def q7_total
    self.q7_1 + self.q7_2 + self.q7_3 + self.q7_4 + self.q7_5
  end

  def q8_total
    self.q8_1 + self.q8_2 + self.q8_3 + self.q8_4 + self.q8_5
  end

  def q9_total
    self.q9_1 + self.q9_2 + self.q9_3 + self.q9_4 + self.q9_5
  end

  def q10_total
    self.q10_1 + self.q10_2 + self.q10_3 + self.q10_4 + self.q10_5
  end

  def q11_total
    self.q11_1 + self.q11_2 + self.q11_3 + self.q11_4 + self.q11_5
  end

  def volume_total
    self.q1_total + self.q2_total + self.q3_total + self.q4_total + self.q5_total + self.q6_total + self.q7_total + self.q8_total + self.q9_total + self.q10_total + self.q11_total
  end
end
