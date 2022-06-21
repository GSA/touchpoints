# frozen_string_literal: true

FactoryBot.define do
  factory :digital_product do
    name { 'ExampleGov Mobile App' }
    service { 'Test Service' }
    url { 'test Url' }
    code_repository_url { 'Test code_repository_url' }
    language { 'Ruby' }
    aasm_state { 'published' }
    short_description { 'test product' }
    long_description { 'a much loooooo oooooooo oooooooo oooooooo oooooooo oooooooo onger description' }
    notes { 'Test notes' }
    tag_list { %w[red green blue] }
    certified_at { Time.zone.now }
  end
end
