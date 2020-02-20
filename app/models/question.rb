class Question < ApplicationRecord
  belongs_to :form, required: true
  belongs_to :form_section, required: true
  has_many :question_options, dependent: :destroy

  MAX_CHARACTERS = 100000

  QUESTION_TYPES = [
    "text_field",
    "textarea",
    "checkbox",
    "radio_buttons",
    "dropdown"
  ]

  validates :answer_field, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_CHARACTERS, allow_nil: true }

  after_save do | question |
    FormCache.invalidate(question.form.short_uuid)
  end

  def max_length
  	return character_limit if character_limit.present?
  	MAX_CHARACTERS
  end

  default_scope { order(position: :asc) }
end
