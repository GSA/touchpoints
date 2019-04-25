class Form < ApplicationRecord
  has_many :touchpoints

  validates :name, presence: true
end
