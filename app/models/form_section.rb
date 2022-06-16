class FormSection < ApplicationRecord
  belongs_to :form
  has_many :questions

  validates :position, presence: true

  after_commit do |form_section|
    FormCache.invalidate(form_section.form.short_uuid) if form_section.form.present?
  end

  before_destroy :ensure_no_questions

  default_scope { order(position: :asc) }

  def ensure_no_questions
    if questions.count > 0
      errors.add(:question_count_error, "This form section cannot be deleted because it still has one or more questions")
      throw(:abort)
    end
  end
end
