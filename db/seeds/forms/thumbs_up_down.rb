module Seeds
  module Forms
    def self.thumbs_up_down
      # Create the A11 Form
      thumbs_up_down = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "a11_v2",
        notes: "Thumbs up/down",
        user: User.first,
        name: "Per page feedback",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        success_text: "Thank you for your response 🎉",
        early_submission: true,
        delivery_method: "modal"
      })

      # Page 1
      question_01 = Question.create!({
        form: thumbs_up_down,
        form_section: (thumbs_up_down.form_sections.first),
        text: "Was this page useful?",
        question_type: "thumbs_up_down_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })

      thumbs_up_down
    end
  end
end
