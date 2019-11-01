FactoryBot.define do
  factory :form_template do
    name { "Open-ended Test form" }
    kind { "custom" }
    notes { "Notes" }
    trait :a11 do
      kind { "a11" }
      name { "A11 Form" }
    end
  end
end
