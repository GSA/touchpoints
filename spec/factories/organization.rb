FactoryBot.define do
  factory :organization do
    name { "Example.gov" }
    domain { "example.gov" }
    abbreviation { "EX" }
    url { "https://example.gov" }
    notes { "Notes about this Organization" }
  end
end
