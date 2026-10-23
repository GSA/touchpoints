# frozen_string_literal: true

class QuestionOption < ApplicationRecord
  belongs_to :question

  before_validation :set_default_value_from_text

  validates :text, presence: true
  validates :value, presence: true
  validates :position, presence: true
  validate :one_other_option_per_question, on: :create

  after_commit do |question_option|
    # Deletions must invalidate the widget as well as edits.
    FormCache.invalidate(question_option.question.form.short_uuid) if question_option.persisted? || question_option.destroyed?
    if question_option.saved_change_to_question_id? && question_option.question_id_before_last_save
      previous_question = Question.find_by(id: question_option.question_id_before_last_save)
      FormCache.invalidate(previous_question.form.short_uuid) if previous_question
    end
  end

  default_scope { order(position: :asc) }

  def set_default_value_from_text
    self.value = text unless value?
  end

  private

  def one_other_option_per_question
    existing_other_option = question && question.question_options.where(other_option: true).exists?

    if self.other_option && existing_other_option
      errors.add(:question_option, "only one 'other_option' can be true for a question")
    end
  end
end
