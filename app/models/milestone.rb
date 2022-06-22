# frozen_string_literal: true

class Milestone < ApplicationRecord
  belongs_to :organization
  belongs_to :goal, optional: true

  validates :name, presence: true
end
