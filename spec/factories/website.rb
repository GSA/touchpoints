FactoryBot.define do
  factory :website do
    domain { "subdomain.example.gov" }
    type_of_site { "application" }
    parent_domain { "example.gov" }
    office { "OFFICE" }
    sub_office { "SUBOFFICE" }
  end
end
