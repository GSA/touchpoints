class Question < ApplicationRecord
  belongs_to :form, required: true
  belongs_to :form_section, required: true
  has_many :question_options, dependent: :destroy

  validates :answer_field, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100000, allow_nil: true }

  after_save do | question |
    TouchpointCache.invalidate(question.form.touchpoint.id) if question.form.touchpoint.present?
  end

  default_scope { order(position: :asc) }
end
