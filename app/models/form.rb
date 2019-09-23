class Form < ApplicationRecord
  has_one :touchpoint
  has_many :questions

  validates :name, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100000 }
  validates_length_of :disclaimer_text, in: 0..500, allow_blank: true

  def success_text
    super.present? ? super : "Thank you. Your feedback has been received."
  end
end
