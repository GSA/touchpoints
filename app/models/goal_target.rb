# frozen_string_literal: true

class GoalTarget < ApplicationRecord
  belongs_to :goal

  validates :assertion, presence: true
end
