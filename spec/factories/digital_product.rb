FactoryBot.define do
  factory :digital_product do
    organization
    user
    service { 'Test Service' }
    url { 'test Url' }
    code_repository_url { 'Test code_repository_url' }
    language { 'Ruby' }
    aasm_status { 'published' }
    short_description { 'test product' }
    long_description { ' adsfasdfadsfadfasdfasfasdfasdf' }
    notes { 'Test notes' }
    tags { 'red green blue' }
    certified_at { Time.now }
  end
end
