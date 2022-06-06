FactoryBot.define do
  factory :digital_product do
    organization
    user
    name { 'ExampleGov Mobile App' }
    service { 'Test Service' }
    url { 'test Url' }
    code_repository_url { 'Test code_repository_url' }
    language { 'Ruby' }
    aasm_state { 'published' }
    short_description { 'test product' }
    long_description { 'a much loooooo oooooooo oooooooo oooooooo oooooooo oooooooo onger description' }
    notes { 'Test notes' }
    tag_list { ['red', 'green', 'blue'] }
    certified_at { Time.now }
  end
end
