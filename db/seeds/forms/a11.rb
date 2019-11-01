module Seeds
  module Forms
    def self.a11
      # Create the A11 Form
      a11_form = Form.create({
        name: "A11 Form",
        kind:  "custom",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        success_text: "Thank you for your submission 🎉",
        notes: "",
        character_limit: 1000,
        early_submission: true
      })
      # Create Page 2
      a11_form.form_sections.create(title: "Page 2", position: 2)

      # Specify the Question Options
      options = ["strongly disagree", "disagree", "neutral", "agree", "strongly agree"]

      # Page 1
      question_01 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.first),
        text: "A-11 Question 1",
        question_type: "radio_buttons",
        position: 1,
        answer_field: :answer_01,
      })
      question_02 = Question.create!({
        form: a11_form,
        form_section: (a11_form.form_sections.first),
        text: "A-11 Question 2",
        question_type: "radio_buttons",
        position: 2,
        answer_field: :answer_02,
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
        options.each_with_index do |option, j|
          QuestionOption.create!({
            question: q,
            text: option,
            position: j
          })
        end
      end

    end
  end
end
