module Seeds
  module Forms
    def self.thumbs_up_down
      # Create the thumbs up/down form
      form = Form.create({
        organization: Organization.first,
        template: true,
        kind:  "custom",
        notes: "Thumbs up/down",
        user: User.first,
        name: "Thumbs up/down per page feedback",
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
        question_type: "thumbs_up_down_buttons",
        position: 1,
        answer_field: :answer_01,
        is_required: true
      })

      form
    end
  end
end
