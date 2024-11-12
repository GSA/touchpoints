# frozen_string_literal: true

FactoryBot.define do
  factory :digital_service_account do
    sequence(:name) { |i| "Service Account #{i}" }
    service { DigitalServiceAccount.list.sample }
    sequence(:service_url) { |i| "https://lvh.me/test#{i}" }
  end
end
