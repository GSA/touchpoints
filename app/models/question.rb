# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :form, counter_cache: true
  belongs_to :form_section
  has_many :question_options, dependent: :destroy

  validates :question_type, presence: true
  validate :validate_question_types
  validates :answer_field, uniqueness: { scope: :form_id }

  default_scope { order(position: :asc) }

  MAX_CHARACTERS = 10_000

  QUESTION_TYPES = [
    # Standard elements
    'text_field',
    'text_email_field',
    'text_phone_field',
    'textarea',
    'checkbox',
    'radio_buttons',
    'dropdown',
    'combobox',
    # Custom elements
    'text_display',
    'custom_text_display',
    'states_dropdown',
    'star_radio_buttons',
    'thumbs_up_down_buttons',
    'big_thumbs_up_down_buttons',
    'yes_no_buttons',
    'hidden_field',
    'date_select',
  ].freeze

  LIMITED_QUESTION_TYPES = [
    # Custom elements
    'combobox',
    'custom_text_display',
    'star_radio_buttons',
    'thumbs_up_down_buttons',
    'big_thumbs_up_down_buttons',
    'yes_no_buttons',
  ].freeze

  validates :answer_field, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_CHARACTERS, allow_nil: true }

  after_commit do |question|
    FormCache.invalidate(question.form.short_uuid) if question.persisted?
  end

  def max_length
    character_limit.present? ? character_limit : MAX_CHARACTERS
  end

  def validate_question_types
    errors.add(:question_type, "Invalid question type '#{question_type}'. Valid types include: #{QUESTION_TYPES.to_sentence}.") unless QUESTION_TYPES.include?(question_type)
  end

  # used to generate a (application-wide) unique id for each question
  # (such that the questions on 2 different Touchpoints have unique DOM string)
  def ui_selector
    if self.form.legacy_form_embed
      self.answer_field.to_sym
    else
      "question_#{self.id}_#{self.answer_field}" # question_123_answer_02
    end
  end
end
