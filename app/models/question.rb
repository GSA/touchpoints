class Question < ApplicationRecord
  belongs_to :form, required: true
  belongs_to :form_section, required: true
  validates :answer_field, presence: true

  default_scope { order(position: :asc) }

  has_many :question_options, dependent: :destroy
end
