FactoryBot.define do
  factory :form_template do
    name { "Open-ended Test form" }
    kind { "open-ended" }
    notes { "Notes" }
    trait :a11 do
      kind { "a11" }
      name { "A11 Form" }
    end
    trait :open_ended_with_contact_info do
      kind { "open-ended-with-contact-info" }
      name { "Open-ended Test form with Contact Info" }
    end
  end
end
