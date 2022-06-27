module Seeds
  module Forms
    def self.a11
      # Create the A11 Form
      a11_form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "a11",
        notes: "Standard A-11 Form in support of the CX CAP Goal",
        user: User.first,
        name: "A11 Form",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        early_submission: true,
        delivery_method: "modal",
        modal_button_text: "Click here to leave feedback"
      })
      # Create Page 2
      a11_form.form_sections.create(title: "Page 2", position: 2)

      # Specify the Question Options
      options = {
        "strongly disagree" => "1",
        "disagree" => "2",
        "neutral" => "3",
        "agree" => "4",
        "strongly agree" => "5"
      }

      # Page 1
      question_01 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.first),
        text: "A-11 Question 1",
        question_type: "radio_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })
      question_02 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.first),
        text: "A-11 Question 2",
        question_type: "radio_buttons",
        position: 2,
        answer_field: :answer_02,
        is_required: true
      })
      question_08 = Question.create!({
        form: a11_form,
        form_section: a11_form.form_sections.first,
        text: "A-11 Question 3",
        question_type: "textarea",
        position: 3,
        answer_field: :answer_08,
      })

      # Page 2
      question_03 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.last),
        text: "A-11 Question 4",
        question_type: "radio_buttons",
        position: 1,
        answer_field: :answer_03,
      })
      question_04 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.last),
        text: "A-11 Question 5",
        question_type: "radio_buttons",
        position: 2,
        answer_field: :answer_04,
      })
      question_05 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.last),
        text: "A-11 Question 6",
        question_type: "radio_buttons",
        position: 3,
        answer_field: :answer_05,
      })
      question_06 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.last),
        text: "A-11 Question 7",
        question_type: "radio_buttons",
        position: 4,
        answer_field: :answer_06,
      })
      question_07 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.last),
        text: "A-11 Question 8",
        question_type: "radio_buttons",
        position: 5,
        answer_field: :answer_07,
      })
      question_09 = Question.create!({
        form: a11_form,
        form_section: a11_form.form_sections.last,
        text: "A-11 Question 9",
        question_type: "textarea",
        position: 6,
        answer_field: :answer_09,
      })

      # Create the Question Options for each Radio Button Question
      [
        question_01,
        question_02,
        question_03,
        question_04,
        question_05,
        question_06,
        question_07,
      ].each do |q|
        options.each_with_index do |(option, value), j|
          QuestionOption.create!({
            question: q,
            text: option,
            value: value,
            position: j + 1
          })
        end
      end

      a11_form
    end
  end
end
