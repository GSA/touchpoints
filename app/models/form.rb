class Form < ApplicationRecord
  has_one :touchpoint

  validates :name, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100000 }
end
