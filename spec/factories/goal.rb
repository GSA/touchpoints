FactoryBot.define do
  factory :goal do
    organization
    name { "Example Performance Goal" }
    description { "A description of this goal." }
    tags { ["this", "that", "other"] }
    users { [] }
  end
end
