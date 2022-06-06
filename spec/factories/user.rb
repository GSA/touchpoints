FactoryBot.define do
  factory :user do
    organization
    sequence(:email) { |n| "webmaster#{n}@example.gov" }
    password { "password" }
    confirmed_at { Time.now }
    trait :admin do
      email { "admin@example.gov" }
      admin { true }
      after(:create) do |u, evaluator|
        FactoryBot.create(:persona,
          user: u,
          name: "Public User"
        )
        FactoryBot.create(:persona,
          user: u,
          name: "Federal Staff User"
        )
        FactoryBot.create(:persona,
          user: u,
          name: "Example Persona 3"
        )
      end
    end
  end
end
