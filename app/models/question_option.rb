# frozen_string_literal: true

class QuestionOption < ApplicationRecord
  belongs_to :question

  before_validation :set_default_value_from_text

  validates :text, presence: true
  validates :value, presence: true
  validates :position, presence: true
  validate :one_other_option_per_question, on: :create

  after_commit do |question_option|
    FormCache.invalidate(question_option.question.form.short_uuid) if question_option.persisted?
  end

  default_scope { order(position: :asc) }

  def set_default_value_from_text
    self.value = text unless value?
  end

  private

  def one_other_option_per_question
    existing_other_option = question.question_options.where(other_option: true)

    if existing_other_option.exists?
      errors.add(:question_option, "only one 'other_option' can be true for a question")
    end
  end
end
