FactoryBot.define do
  factory :user do
    email { "admin@example.com" }
    password { "password" }
    confirmed_at { Time.now }
    trait :admin do
      admin { true }
    end
  end
end
