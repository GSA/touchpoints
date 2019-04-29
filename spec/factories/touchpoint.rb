FactoryBot.define do
  factory :touchpoint do
    service
    name { "Example Touchpoint" }
    expiration_date { Time.now + 2.months }
    omb_approval_number { rand(10000).to_s }
    form
  end
end
