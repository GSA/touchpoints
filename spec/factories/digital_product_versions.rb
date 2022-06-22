# frozen_string_literal: true

FactoryBot.define do
  factory :digital_product_versions do
    digital_product
    store_url { 'https/something.com' }
    platform { 'iOS' }
    version_number { '1.9' }
    publish_date { Date.today }
    description { 'Test description' }
    whats_new { 'things' }
    screenshot_url { 'https://something.com/image' }
    device { 'tablet' }
    language { 'ObjectiveC' }
    average_rating { '4.5' }
    number_of_ratings { 25 }
  end
end
