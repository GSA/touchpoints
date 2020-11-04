module Seeds
  module Forms

    # Create a Custom Form with a 2nd Page/Form Section
    def self.kitchen_sink
      custom_form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "kitchen sink",
        notes: "An example form that uses one of every form element",
        name: "Kitchen Sink Form Template",
        title: "Kitchen Sink Form 🧼",
        user: User.first,
        instructions: "Instruction text goes here",
        disclaimer_text: "Disclaimer text goes Here",
        omb_approval_number: "1234-5678",
        expiration_date: Time.now + 2.years,
        success_text: "Thank you for your response 🎉",
        delivery_method: "touchpoints-hosted-only"
      })
      text_elements_section = custom_form.form_sections.first
      text_elements_section.update_attribute(:title, "Text elements")

      Question.create!({
        form: custom_form,
        form_section: text_elements_section,
        text: "Custom Question Text Field",
        question_type: "text_field",
        position: 1,
        answer_field: :answer_01,
        is_required: false,
      })
      Question.create!({
        form: custom_form,
        form_section: text_elements_section,
        text: "Custom Question Text Field",
        question_type: "text_email_field",
        position: 2,
        answer_field: :answer_02,
        is_required: false,
      })
      Question.create!({
        form: custom_form,
        form_section: text_elements_section,
        text: "Custom Question Text Area",
        question_type: "textarea",
        position: 3,
        answer_field: :answer_03,
        is_required: false,
      })

      option_elements_section = custom_form.form_sections.create(title: "Option elements", position: 2)
      radio_button_question = Question.create!({
        form: custom_form,
        form_section: option_elements_section,
        text: "Custom Question Radio Buttons",
        question_type: "radio_buttons",
        position: 4,
        answer_field: :answer_04,
        is_required: false,
      })
      QuestionOption.create!({
        question: radio_button_question,
        text: "Option 1",
        value: 1,
        position: 1
      })
      QuestionOption.create!({
        question: radio_button_question,
        text: "Option 2",
        value: 2,
        position: 2
      })
      QuestionOption.create!({
        question: radio_button_question,
        text: "Option 3",
        value: 3,
        position: 3
      })

      checkbox_question = Question.create!({
        form: custom_form,
        form_section: option_elements_section,
        text: "Custom Question Checkboxes",
        question_type: "checkbox",
        position: 4,
        answer_field: :answer_04,
        is_required: false,
      })
      QuestionOption.create!({
        question: checkbox_question,
        text: "Option 1",
        value: 1,
        position: 1
      })
      QuestionOption.create!({
        question: checkbox_question,
        text: "Option 2",
        value: 2,
        position: 2
      })
      QuestionOption.create!({
        question: checkbox_question,
        text: "Other",
        value: 3,
        position: 3
      })
      QuestionOption.create!({
        question: checkbox_question,
        text: "Otro",
        value: 4,
        position: 4
      })

      dropdown_question = Question.create!({
        form: custom_form,
        form_section: option_elements_section,
        text: "Custom Question Dropdown",
        question_type: "dropdown",
        position: 5,
        answer_field: :answer_05,
        is_required: false,
      })
      QuestionOption.create!({
        question: dropdown_question,
        text: "Option 1",
        value: 1,
        position: 1
      })
      QuestionOption.create!({
        question: dropdown_question,
        text: "Option 2",
        value: 2,
        position: 2
      })
      QuestionOption.create!({
        question: dropdown_question,
        text: "Option 3",
        value: 3,
        position: 3
      })

      custom_elements_section = custom_form.form_sections.create(title: "Custom elements", position: 3)
      Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: '<p>Custom text <a href="#">that supports HTML</a> goes here.</p>',
        question_type: "text_display",
        position: 6,
        answer_field: :answer_06,
        is_required: false,
      })

      Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: "Custom text display",
        question_type: "custom_text_display",
        position: 7,
        answer_field: :answer_07,
        is_required: false
      })

      Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: "Star radio buttons",
        question_type: "star_radio_buttons",
        position: 8,
        answer_field: :answer_08,
        is_required: false
      })

      Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: "Thumbs up/down buttons",
        question_type: "thumbs_up_down_buttons",
        position: 9,
        answer_field: :answer_09,
        is_required: false
      })

      Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: "Yes/No buttons",
        question_type: "yes_no_buttons",
        position: 10,
        answer_field: :answer_10,
        is_required: false
      })

      matrix_checkbox_question = Question.create!({
        form: custom_form,
        form_section: custom_elements_section,
        text: "Matrix checkboxes",
        question_type: "matrix_checkboxes",
        position: 11,
        answer_field: :answer_11,
        is_required: false
      })

      QuestionOption.create!({
        question: matrix_checkbox_question,
        text: "Option 1",
        value: 1,
        position: 1
      })
      QuestionOption.create!({
        question: matrix_checkbox_question,
        text: "Option 2",
        value: 2,
        position: 2
      })
      QuestionOption.create!({
        question: matrix_checkbox_question,
        text: "Option 3",
        value: 3,
        position: 3
      })
      QuestionOption.create!({
        question: matrix_checkbox_question,
        text: "Option 4",
        value: 4,
        position: 4
      })

      custom_form
    end
  end
end
