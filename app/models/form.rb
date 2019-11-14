class Form < ApplicationRecord
  has_one :touchpoint
  has_many :questions
  has_many :form_sections

  validates :name, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100000 }
  validates_length_of :disclaimer_text, in: 0..500, allow_blank: true

  after_create :create_first_form_section

  def create_first_form_section
    self.form_sections.create(title: (I18n.t 'form.page_1'), position: 1)
  end

  def success_text
    super.present? ? super : (I18n.t 'form.submit_thankyou')
  end

  def modal_button_text
    super.present? ? super : (I18n.t 'form.help_improve')
  end
end
