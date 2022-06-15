# frozen_string_literal: true

FactoryBot.define do
  factory :milestone do
    organization
    name { 'Example Performance Milestone' }
    description { 'A description about an example Milestone' }
    status { 'on_track' }
    notes { 'Extra text about a milestone' }
  end
end
