class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :position, presence: true

  after_save do | question_option |
    TouchpointCache.invalidate(question_option.question.form.touchpoint.short_uuid) if question_option.question.form.touchpoint.present?
  end

  default_scope { order(position: :asc) }
end
