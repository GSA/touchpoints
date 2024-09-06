# frozen_string_literal: true

class Goal < ApplicationRecord
  resourcify

  belongs_to :organization
  belongs_to :user, optional: true
  has_many :milestones
  has_many :objectives
  has_many :goal_targets
  acts_as_taggable_on :tags, :organizations

  before_create :set_position

  validates :name, presence: true

  scope :strategic_goals, -> { where(four_year_goal: true) }
  scope :annual_performance_goals, -> { where(four_year_goal: false) }

  delegate :name, to: :organization, prefix: true
  delegate :abbreviation, to: :organization, prefix: true

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
    'Workforce development & employment',
  ].freeze

  def subgoals
    Goal.where(parent_id: id)
  end

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end

  def sponsoring_users
    User.with_role(:sponsor, self)
  end

  def create_roles
    service_owner.add_role :service_manager, self
  end

  private

  # default a new goal's position to the max position + 1 for the organization
  def set_position
    if organization.goals.reload.present?
      self.position = organization.goals.maximum(:position) + 1
    else
      self.position = 1
    end
  end
end
