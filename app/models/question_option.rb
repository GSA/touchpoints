class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :position, presence: true

  default_scope { order(position: :asc) }
end
