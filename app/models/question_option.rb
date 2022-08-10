# frozen_string_literal: true

class QuestionOption < ApplicationRecord
  belongs_to :question

  before_save :set_default_value_from_text

  validates :text, presence: true
  validates :position, presence: true

  def set_default_value_from_text
    self.value = text unless value?
  end

  after_commit do |question_option|
    FormCache.invalidate(question_option.question.form.short_uuid) if question_option.persisted?
  end

  default_scope { order(position: :asc) }
end
