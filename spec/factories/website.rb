# frozen_string_literal: true

FactoryBot.define do
  factory :website do
    sequence(:domain) { |n| "subdomain#{n}.example.gov" }
    type_of_site { 'application' }
    office { 'OFFICE' }
    sub_office { 'SUBOFFICE' }
  end
end
