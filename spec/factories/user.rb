FactoryBot.define do
  factory :user do
    organization
    sequence(:email) { |n| "webmaster#{n}@example.gov" }
    password { "password" }
    confirmed_at { Time.now }
    trait :admin do
      email { "admin@example.gov" }
      admin { true }
    end
  end
end
