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

    omb_approval_number { rand(10000).to_s }
    expiration_date { Time.now + 2.months }
    aasm_state { "live"}
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

  end
end
