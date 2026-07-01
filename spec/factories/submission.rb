# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    answer_01 { 'submission response body text' }
    form

    trait :a11 do
      answer_01 { '1' }
      answer_02 { '2' }
      answer_03 { '3' }
      answer_04 { '4' }
      answer_05 { '5' }
      answer_06 { '4' }
      answer_07 { '3' }
      answer_08 { 'text 1' }
      answer_09 { 'text 2' }
    end

    trait :with_documented_metadata do
      page { '/' }
      user_agent { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36'}
      ip_address { '62.107.32.31' }
      location_code { '' }
      language { 'en' }
      referer { 'https://feedback.usa.gov/about/' }
      hostname { 'touchpoints.digital.gov' }
    end
  end
end
