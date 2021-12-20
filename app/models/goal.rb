class Goal < ApplicationRecord
  belongs_to :organization
  has_many :milestones

  validates :name, presence: true

  def subgoals
    Goal.where(parent_id: self.id)
  end
end
