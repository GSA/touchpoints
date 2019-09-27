FactoryBot.define do
  factory :question do
    text { "Test Question" }
    question_type { "text_field" }
    answer_field { "answer_01" }

    trait :radio_buttons do
      text { "Test Radio Buttons Question" }
      question_type { "radio_buttons" }
    end
  end
end
