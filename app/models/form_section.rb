class FormSection < ApplicationRecord
  belongs_to :form
  has_many :questions

  after_save do | form_section |
    TouchpointCache.invalidate(form_section.form.touchpoint.short_uuid) if form_section.form.touchpoint.present?
  end

  default_scope { order(position: :asc) }

end
