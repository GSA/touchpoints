FactoryBot.define do
  factory :form do
    name { "Open-ended Test form" }
    kind { "open-ended" }
    notes { "Notes" }
    trait :a11 do
      kind { "a11" }
    end
    trait :recruiter do
      kind { "recruiter" }
    end
  end
end
