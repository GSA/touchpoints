class FormSection < ApplicationRecord
  belongs_to :form
  has_many :questions

  default_scope { order(position: :asc) }

  def title
    super ? super : "Unnamed Form Section Title"
  end
end
