module Seeds
  module Forms
    def self.yes_no
      # Create the yes/no buttons form
      form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "yes_no",
        notes: "Yes/No Form",
        user: User.first,
        name: "Yes/No per page feedback",
        title: "",
        instructions: "",
        disclaimer_text: "",
        delivery_method: "inline",
        element_selector: "an-html-id"
      })

      form.form_sections.first.update_attribute(:title, nil)

      # Page 1
      question_01 = Question.create!({
        form: form,
        form_section: (form.form_sections.first),
        text: "Was this page useful?",
        question_type: "yes_no_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })

      form
    end
  end
end
