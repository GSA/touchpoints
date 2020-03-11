module Seeds
  module Forms
    def self.yes_no
      # Create the yes/no buttons form
      form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "custom",
        notes: "Yes/No Form",
        user: User.first,
        name: "Per page feedback",
        title: "",
        instructions: "",
        disclaimer_text: "Disclaimer Text Goes Here",
        success_text: "Thank you for your response 🎉",
        delivery_method: "modal"
      })

      # Page 1
      question_01 = Question.create!({
        form: form,
        form_section: (form.form_sections.first),
        text: "",
        question_type: "yes_no_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })

      form
    end
  end
end
