# frozen_string_literal: true

class QuestionSerializer < ActiveModel::Serializer
  attributes :id,
             :form_id,
             :text,
             :question_type,
             :answer_field,
             :position,
             :is_required,
             :created_at,
             :updated_at,
             :form_section_id,
             :character_limit,
             :placeholder_text,
             :help_text

  has_many :question_options

  def position
    # Normalize position based on the order within the form's ordered questions
    form_questions = object.form.ordered_questions
    form_questions.index(object) + 1
  end
end