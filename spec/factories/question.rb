FactoryBot.define do
  factory :question do
    text { "Test Question" }
    question_type { "text_field" }
    answer_field { "answer_01" }

    trait :with_radio_buttons do
      text { "Test Radio Buttons Question" }
      question_type { "radio_buttons" }
      after(:create) do |radio_button_question, evaluator|
        FactoryBot.create(:question_option, question: radio_button_question, position: 1)
        FactoryBot.create(:question_option, question: radio_button_question, position: 2)
        FactoryBot.create(:question_option, question: radio_button_question, position: 3)
        FactoryBot.create(:question_option, question: radio_button_question, position: 4)
        FactoryBot.create(:question_option, question: radio_button_question, position: 5)
      end
    end

    trait :with_checkbox_options do
      text { "Test Radio Buttons Question" }
      question_type { "checkboxes" }
      after(:create) do |checkbox_question, evaluator|
        FactoryBot.create(:question_option, question: checkbox_question, position: 1)
        FactoryBot.create(:question_option, question: checkbox_question, position: 2)
        FactoryBot.create(:question_option, question: checkbox_question, position: 3)
        FactoryBot.create(:question_option, question: checkbox_question, position: 4)
      end
    end
  end
end
