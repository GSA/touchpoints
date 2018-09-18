FactoryBot.define do
  factory :user do
    email { "admin@example.com" }
    password { "password" }
    confirmed_at { Time.now }
  end
end
