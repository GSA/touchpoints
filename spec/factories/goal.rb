# frozen_string_literal: true

FactoryBot.define do
  factory :goal do
    organization
    name { 'Example Performance Goal' }
    description { 'A description of this goal.' }
    users { [] }
  end
end
