class FormSection < ApplicationRecord
  belongs_to :form
  has_many :questions

  def title
    super ? super : "Unnamed Form Section Title"
  end
end
