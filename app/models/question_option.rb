class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :text, presence: true
  validates :position, presence: true

  after_commit do |question_option|
    FormCache.invalidate(question_option.question.form.short_uuid)
  end

  default_scope { order(position: :asc) }
end
