FactoryBot.define do
  factory :user do
    email { "webmaster@example.gov" }
    organization
    password { "password" }
    confirmed_at { Time.now }
    trait :admin do
      email { "admin@example.gov" }
      admin { true }
    end
    trait :organization_manager do
      email { "organization_manager@example.gov" }
      organization_manager { true }
    end
  end
end
