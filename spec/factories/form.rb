FactoryBot.define do
  factory :form do
    name { "Open-ended Test form" }
    title { "Do you have a few minutes to help us test this site?" }
    kind { "open-ended" }
    notes { "Notes" }
    character_limit { 1000 }
    trait :a11 do
      kind { "a11" }
    end
    trait :recruiter do
      kind { "recruiter" }
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
  end
end
