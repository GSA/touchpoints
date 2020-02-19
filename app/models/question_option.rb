class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :position, presence: true

  after_save do | question_option |
    FormCache.invalidate(question_option.question.form.short_uuid) if question_option.question.form.present?
  end

  default_scope { order(position: :asc) }
end
