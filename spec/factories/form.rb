FactoryBot.define do
  factory :form do
    user
    organization
    name { "Open-ended Test form" }
    title { "Do you have a few minutes to help us test this site?" }
    kind { "custom" }
    notes { "Notes" }
    success_text { "Thank you. Your feedback has been received." }
    modal_button_text { "Help improve this site" }
    legacy_touchpoint_id { 123 }
    legacy_touchpoint_uuid { "ABCD1234" }
    notification_emails { user.email }

    omb_approval_number { rand(10000).to_s }
    expiration_date { Time.now + 2.months }
    aasm_state { "live" }
    delivery_method { "modal" }

    trait :touchpoints_hosted_only do
      delivery_method { "touchpoints-hosted-only" }
    end
    trait :inline do
      delivery_method { "inline" }
      element_selector { "touchpoints-div-id" }
    end
    trait :custom_button_modal do
      delivery_method { "custom-button-modal" }
      element_selector { "existing-website-button-id" }
    end

    trait :recruiter do
      name { "Recruiter" }
      kind { "custom" }
      after(:create) do |f, evaluator|
        FactoryBot.create(:question,
          form: f,
          question_type: "text_field",
          form_section: f.form_sections.first,
          answer_field: "answer_01",
          position: 1,
          text: "Name"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "text_field",
          form_section: f.form_sections.first,
          answer_field: "answer_02",
          position: 2,
          text: "Email"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "text_field",
          form_section: f.form_sections.first,
          answer_field: "answer_03",
          position: 3,
          text: "Phone Number"
        )
      end
    end

    trait :custom do
      name { "Custom Test form" }
      kind { "custom" }
    end

    trait :open_ended_form do
      name { "Open-ended Test form" }
      kind { "custom" }
      after(:create) do |f, evaluator|
        FactoryBot.create(:question,
          form: f,
          answer_field: :answer_01,
          question_type: "textarea",
          form_section: f.form_sections.first,
          text: "Test Open Area"
        )
      end
    end

    trait :open_ended_form_with_contact_information do
      name { "Open-ended Test form with Contact Information" }
      kind { "custom" }
      after(:create) do |f, evaluator|
        FactoryBot.create(:question,
          form: f,
          question_type: "textarea",
          form_section: f.form_sections.first,
          text: "Body"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "textarea",
          form_section: f.form_sections.first,
          text: "Name"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "textarea",
          form_section: f.form_sections.first,
          text: "Email"
        )
      end
    end

    trait :kitchen_sink do
      name { "Kitchen Sink Form 🧼" }
      kind { "custom" }
      after(:create) do |f, evaluator|
        FactoryBot.create(:question,
          form: f,
          question_type: "text_field",
          form_section: f.form_sections.first,
          answer_field: "answer_01",
          position: 1,
          text: "An input field"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "text_display",
          form_section: f.form_sections.first,
          answer_field: "answer_20",
          position: 2,
          text: "Some custom <a href='#'>html</a>"
        )
        FactoryBot.create(:question,
          form: f,
          question_type: "textarea",
          form_section: f.form_sections.first,
          answer_field: "answer_02",
          position: 3,
          text: "A textarea field"
        )
      end
    end

    trait :a11_v2 do
      name { "Version 2 of the A11 form" }
      kind { "custom" }
      after(:create) do |f, evaluator|
        FactoryBot.create(:question,
          :with_radio_buttons,
          form: f,
          answer_field: :answer_01,
          question_type: "star_radio_buttons",
          form_section: f.form_sections.first,
          text: "Please rate your experience as a customer of Agency of Departments."
        )
        FactoryBot.create(:question,
          :with_checkbox_options,
          form: f,
          answer_field: :answer_02,
          question_type: "matrix_checkboxes",
          form_section: f.form_sections.first,
          text: "Name"
        )
        FactoryBot.create(:question,
          form: f,
          answer_field: :answer_03,
          question_type: "textarea",
          form_section: f.form_sections.first,
          text: "Additional comments"
        )
      end
    end

  end
end
