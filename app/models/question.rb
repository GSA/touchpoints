class Question < ApplicationRecord
  belongs_to :form, required: true
  belongs_to :form_section, required: true
  validates :answer_field, presence: true

  after_save do | question |
    TouchpointCache.invalidate(question.form.touchpoint.id) if question.form.touchpoint.present?
  end

  default_scope { order(position: :asc) }

  has_many :question_options, dependent: :destroy
end
