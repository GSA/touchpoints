class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :position, presence: true
end
