class Form < ApplicationRecord
  belongs_to :user
  has_one :touchpoint
  has_many :questions
  has_many :form_sections

  validates :name, presence: true
  validates :character_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100000 }
  validates_length_of :disclaimer_text, in: 0..500, allow_blank: true

  after_create :create_first_form_section

  after_save do |form|
    TouchpointCache.invalidate(form.touchpoint.id) if form.touchpoint.present?
  end

  def self.templates
    Form.all.where(template: true)
  end

  def create_first_form_section
    self.form_sections.create(title: (I18n.t 'form.page_1'), position: 1)
  end

  def duplicate!(user:)
    new_form = self.dup
    new_form.name = "Copy of #{self.name}"
    new_form.template = false
    new_form.user = user
    new_form.save

    # Manually remove the Form Section created with create_first_form_section
    new_form.form_sections.destroy_all

    # Loop Form Sections to create them for new_form
    self.form_sections.each do |section|
      new_form_section = section.dup
      new_form_section.form = new_form
      new_form_section.save

      # Loop Questions to create them for new_form and new_form_sections
      section.questions.each do |question|
        new_question = question.dup
        new_question.form = new_form
        new_question.form_section = new_form_section
        new_question.save

        # Loop Questions to create them for Questions
        question.question_options.each do |option|
          new_question_option = option.dup
          new_question_option.question = new_question
          new_question_option.save
        end
      end
    end

    return new_form
  end

end
