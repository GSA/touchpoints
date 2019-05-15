FactoryBot.define do
  factory :form do
    name { "Open-ended Test form" }
    title { "Do you have a few minutes to help us test this site?" }
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
