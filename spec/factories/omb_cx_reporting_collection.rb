# frozen_string_literal: true

FactoryBot.define do
  factory :omb_cx_reporting_collection do
    collection
    service_provided { 'Test Data Collection' }
    transaction_point { 'After sign up process for a new service' }
    channel { :mobile }
    q1_1 { rand(1000) }
    q1_2 { rand(1000) }
    q1_3 { rand(1000) }
    q1_4 { rand(1000) }
    q1_5 { rand(1000) }
  end
end
