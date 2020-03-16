class FormSection < ApplicationRecord
  belongs_to :form
  has_many :questions

  validates :position, presence: true

  after_commit do | form_section |
    FormCache.invalidate(form_section.form.short_uuid) if form_section.form.present?
  end

  default_scope { order(position: :asc) }

end
