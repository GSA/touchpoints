module Seeds
  module Forms
    def self.a11_v2
      # Create the A11 Form
      a11_v2_form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "a11_v2",
        notes: "Second iteration of the CX CAP Goal A-11 form",
        user: User.first,
        name: "Version 2 of the A-11 Form",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        early_submission: true,
        delivery_method: "modal",
        modal_button_text: "Click here to leave feedback"
      })

      # Page 1
      question_01 = Question.create!({
        form: a11_v2_form,
        form_section: (a11_v2_form.form_sections.first),
        text: "Please rate your experience",
        question_type: "star_radio_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })
      question_02 = Question.create!({
        form: a11_v2_form,
        form_section: (a11_v2_form.form_sections.first),
        text: "What went well?",
        question_type: "checkbox",
        position: 2,
        answer_field: :answer_02,
        is_required: true
      })
      [1, 2, 3, 4].each_with_index do |value, i|
        QuestionOption.create!({
          question: question_02,
          text: value.to_s,
          value: value,
          position: i + 1
        })
      end
      question_03 = Question.create!({
        form: a11_v2_form,
        form_section: (a11_v2_form.form_sections.first),
        text: "Additional Comments",
        question_type: "textarea",
        position: 3,
        answer_field: :answer_03,
      })

      a11_v2_form
    end
  end
end
