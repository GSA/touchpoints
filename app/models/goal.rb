class Goal < ApplicationRecord
  belongs_to :organization
  has_many :milestones
  has_many :objectives

  validates :name, presence: true

  scope :strategic_goals, -> { where(four_year_goal: true) }
  scope :annual_performance_goals, -> { where(four_year_goal: false) }

  def subgoals
    Goal.where(parent_id: self.id)
  end
end
