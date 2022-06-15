# frozen_string_literal: true

class Goal < ApplicationRecord
  belongs_to :organization
  has_many :milestones
  has_many :objectives
  has_many :goal_targets
  acts_as_taggable_on :tags

  validates :name, presence: true

  scope :strategic_goals, -> { where(four_year_goal: true) }
  scope :annual_performance_goals, -> { where(four_year_goal: false) }

  TAGS = [
    'Administration of justice',
    'Agriculture',
    'Artificial Intelligence R&D',
    'Quantum information science R&D',
    'Climate change',
    'Commerce & trade',
    'Cybersecurity',
    'Domestic health',
    'Economic development',
    'Economic security & policy',
    'Education',
    'Energy',
    'Environmental justice',
    'Equity',
    'General government & management',
    'General science, space, and technology',
    'Global health',
    'Housing',
    'Income security',
    'Internal affairs',
    'Medicare',
    'National security',
    'Native American & tribal communities',
    'Pandemic response',
    'Social security',
    'Social services',
    'Transportation infrastructure',
    'Veterens benefits & services',
    'Workforce benefits & services',
    'Workforce development & employment'
  ].freeze

  def subgoals
    Goal.where(parent_id: id)
  end

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true
end
