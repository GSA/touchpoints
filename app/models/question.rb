class Question < ApplicationRecord
  belongs_to :form, required: true
  belongs_to :form_section, required: true
  has_many :question_options, dependent: :destroy

  MAX_CHARACTERS = 100000

  QUESTION_TYPES = [
    # Standard elements
    "text_field",
    "textarea",
    "checkbox",
    "radio_buttons",
    "dropdown",
    # Custom elements
    "star_radio_buttons",
    "thumbs_up_down_buttons",
    "yes_no_buttons",
    "matrix_checkboxes",
    "custom_text_display"
  ]

  validates :answer_field, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_CHARACTERS, allow_nil: true }

  after_commit do |question|
    FormCache.invalidate(question.form.short_uuid)
  end

  def max_length
  	return character_limit if character_limit.present?
  	MAX_CHARACTERS
  end

  default_scope { order(position: :asc) }
end
