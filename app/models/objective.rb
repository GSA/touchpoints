# frozen_string_literal: true

class Objective < ApplicationRecord
  belongs_to :organization
  belongs_to :goal, counter_cache: true

  acts_as_taggable_on :tags

  before_create :set_position

  validates :name, presence: true

  def organization_name
    organization&.name
  end

  private

  # default a new objectives's position to the max position + 1 for the goal
  def set_position
    if goal.objectives.reload.present?
      self.position = goal.objectives.maximum(:position) + 1
    else
      self.position = 1
    end
  end
end
