module Seeds
  module Forms

    # Create a Custom Form with a 2nd Page/Form Section
    def self.kitchen_sink
      custom_form = Form.create({
        name: "Kitchen Sink Form",
        kind:  "custom",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        success_text: "Thank you for your submission 🎉",
        notes: "",
        character_limit: 1000
      })
      custom_form.form_sections.create(title: "Page 2", position: 2)

      Question.create!({
        form: custom_form,
        form_section: custom_form.form_sections.first,
        text: "Custom Question Text Field",
        question_type: "text_field",
        position: 1,
        answer_field: :answer_01,
        is_required: false,
      })
      Question.create!({
        form: custom_form,
        form_section: custom_form.form_sections.first,
        text: "Custom Question Text Area",
        question_type: "textarea",
        position: 2,
        answer_field: :answer_02,
        is_required: false,
      })

      radio_button_question = Question.create!({
        form: custom_form,
        form_section: custom_form.form_sections.last,
        text: "Custom Question Radio Buttons",
        question_type: "radio_buttons",
        position: 3,
        answer_field: :answer_03,
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
        form_section: custom_form.form_sections.last,
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
        text: "Option 3",
        value: 3,
        position: 3
      })

      dropdown_question = Question.create!({
        form: custom_form,
        form_section: custom_form.form_sections.last,
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

      custom_form
    end
  end
end
