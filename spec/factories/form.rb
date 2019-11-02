FactoryBot.define do
  factory :form do
    name { "Open-ended Test form" }
    title { "Do you have a few minutes to help us test this site?" }
    kind { "custom" }
    notes { "Notes" }
    character_limit { 1000 }

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

    trait :open_ended_form do
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
