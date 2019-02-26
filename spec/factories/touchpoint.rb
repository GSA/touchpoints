FactoryBot.define do
  factory :touchpoint do
    container
    name { "Example Touchpoint" }
    omb_approval_number { rand(10000).to_s }
    form
  end
end
