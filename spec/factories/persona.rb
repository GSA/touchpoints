# frozen_string_literal: true

FactoryBot.define do
  factory :persona do
    user_id { 1 }
    name { 'test persona name' }
  end
end
