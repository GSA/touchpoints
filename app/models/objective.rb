class Objective < ApplicationRecord
  belongs_to :goal

  validates :name, presence: true
end
