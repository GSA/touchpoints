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
  end
end
