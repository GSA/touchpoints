# frozen_string_literal: true

FactoryBot.define do
  factory :objective do
    organization
    goal
    name { 'Example Performance Objective' }
    description { 'A description of this objective.' }
  end
end
