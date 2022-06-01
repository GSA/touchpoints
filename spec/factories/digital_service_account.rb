FactoryBot.define do
  factory :digital_service_account do
    organization
    user
    sequence(:name) { |i| "Service Account #{i}"}
  end
end
