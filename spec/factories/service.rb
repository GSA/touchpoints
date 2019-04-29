FactoryBot.define do
  factory :service do
    sequence :name do |i|
      "Test Service #{i}"
    end
    description { "A description of this Service - goal, actors, resources" }
    organization
  end
end
