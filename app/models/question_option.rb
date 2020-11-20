class QuestionOption < ApplicationRecord
  belongs_to :question

  before_save :set_default_value_from_text

  validates :text, presence: true
  validates :position, presence: true

  def set_default_value_from_text
    unless self.value?
      self.value = self.text
    end
  end

  after_commit do |question_option|
    FormCache.invalidate(question_option.question.form.short_uuid)
  end

  default_scope { order(position: :asc) }
end
