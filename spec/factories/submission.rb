# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    answer_01 { 'submission response body text' }
    form
  end
end
