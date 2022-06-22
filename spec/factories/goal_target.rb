# frozen_string_literal: true

FactoryBot.define do
  factory :goal_target do
    organization
    goal
    assertion { "text about what we're assertion in regards to performance" }
    starting_value { 1 }
    current_value { 10 }
    target_value { 100 }
  end
end
