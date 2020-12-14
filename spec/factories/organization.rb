FactoryBot.define do
  factory :organization do
    name { "Example.gov" }
    domain { "example.gov" }
    abbreviation { "EX" }
    url { "https://example.gov" }
    notes { "Notes about this Organization" }

    trait :another do
      name { "Another.gov" }
      domain { "another.gov" }
      abbreviation { "AN" }
      url { "https://another.gov" }
      notes { "Notes about another Organization" }
    end
  end
end
