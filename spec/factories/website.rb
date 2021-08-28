FactoryBot.define do
  factory :website do
    sequence(:domain) { |n| "subdomain#{n}.example.gov" }
    type_of_site { "application" }
    parent_domain { "example.gov" }
    office { "OFFICE" }
    sub_office { "SUBOFFICE" }
  end
end
