FactoryBot.define do
  factory :website do
    domain { "subdomain.example.gov" }
    parent_domain { "example.gov" }
    office { "OFFICE" }
    sub_office { "SUBOFFICE" }
  end
end
