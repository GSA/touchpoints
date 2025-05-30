# frozen_string_literal: true

FactoryBot.define do
  factory :form do
    organization
    name { 'Open-ended Test form' }
    title { 'Do you have a few minutes to help us test this site?' }
    kind { 'custom' }
    notes { 'Notes' }
    success_text_heading { 'Success' }
    success_text { 'Thank you. Your feedback has been received.' }
    modal_button_text { 'Help improve this site' }
    legacy_touchpoint_id { 123 }
    legacy_touchpoint_uuid { 'ABCD1234' }

    omb_approval_number { rand(10_000).to_s }
    expiration_date { 2.months.from_now }
    aasm_state { 'published' }
    delivery_method { 'modal' }

    trait :single_question do
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
          form: f,
          question_type: 'text_field',
          form_section: f.form_sections.first,
          answer_field: 'answer_01',
          position: 1,
          text: 'Name')
      end
    end

    trait :touchpoints_hosted_only do
      delivery_method { 'touchpoints-hosted-only' }
    end
    trait :inline do
      delivery_method { 'inline' }
      element_selector { 'touchpoints-div-id' }
    end
    trait :custom_button_modal do
      delivery_method { 'custom-button-modal' }
      element_selector { 'existing-website-button-id' }
    end

    trait :with_responses do
      after(:create) do |f, _evaluator|
        3.times { FactoryBot.create(:submission, form: f) }
      end
    end

    trait :with_100_responses do
      after(:create) do |f, _evaluator|
        100.times { FactoryBot.create(:submission, form: f) }
      end
    end

    trait :recruiter do
      name { 'Recruiter' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_field',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_01',
                          position: 1,
                          text: 'Name')
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_field',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_02',
                          position: 2,
                          text: 'Email')
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_field',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_03',
                          position: 3,
                          text: 'Phone Number')
      end
    end

    trait :star_ratings do
      name { 'Star Ratings' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        Question.create!({
                           form: f,
                           form_section: f.form_sections.first,
                           text: 'Star radio button 1',
                           question_type: 'star_radio_buttons',
                           position: 1,
                           answer_field: :answer_01,
                           is_required: false,
                         })
        Question.create!({
                           form: f,
                           form_section: f.form_sections.first,
                           text: 'Star radio button 2',
                           question_type: 'star_radio_buttons',
                           position: 2,
                           answer_field: :answer_02,
                           is_required: false,
                         })
        Question.create!({
                           form: f,
                           form_section: f.form_sections.first,
                           text: 'Star radio button 3',
                           question_type: 'star_radio_buttons',
                           position: 3,
                           answer_field: :answer_03,
                           is_required: false,
                         })
      end
    end

    trait :custom do
      name { 'Custom Test form' }
      kind { 'custom' }
    end

    trait :open_ended_form do
      name { 'Open-ended Test form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Test Open Area email')
      end
    end

    trait :two_question_open_ended_form do
      name { 'Open-ended Test form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          position: 1,
                          question_type: 'text_field',
                          form_section: f.form_sections.first,
                          text: 'Test Text Field')

        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_02,
                          position: 2,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Test Open Area')
      end
    end

    trait :hidden_field_form do
      name { 'Hidden Field Test form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          form_section: f.form_sections.first,
                          answer_field: :answer_01,
                          text: 'hidden value',
                          placeholder_text: 'hidden value',
                          question_type: 'hidden_field',
                          position: 1,
                          is_required: false)
      end
    end

    trait :open_ended_form_with_contact_information do
      name { 'Open-ended Test form with Contact Information' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Body')
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_02,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Name')
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_03,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Email')
      end
    end

    trait :date_select do
      name { 'Open-ended Test form with Date Select' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'date_select',
                          form_section: f.form_sections.first,
                          answer_field: :answer_04,
                          text: 'Body')
      end
    end

    trait :kitchen_sink do
      name { 'Kitchen Sink Form 🧼' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_field',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_01',
                          position: 1,
                          text: 'An input field')
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_email_field',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_02',
                          position: 2,
                          text: 'An email field')
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          answer_field: 'answer_03',
                          position: 3,
                          text: 'A textarea field')
        FactoryBot.create(:question,
                          form: f,
                          question_type: 'text_display',
                          form_section: f.form_sections.last,
                          answer_field: 'answer_20',
                          position: 20,
                          text: "Some custom <a href='#'>html</a>")

        option_elements_section = f.form_sections.create(title: 'Option elements', position: 2)
        radio_button_question = FactoryBot.create(:question,
                                                  form: f,
                                                  form_section: option_elements_section,
                                                  text: 'Custom Question Radio Buttons',
                                                  question_type: 'radio_buttons',
                                                  help_text: 'This is help text for radio buttons.',
                                                  answer_field: :answer_04,
                                                  position: 4,
                                                  is_required: false)

        QuestionOption.create!({
                                 question: radio_button_question,
                                 text: 'Option 1',
                                 value: 1,
                                 position: 1,
                               })
        QuestionOption.create!({
                                 question: radio_button_question,
                                 text: 'Option 2',
                                 value: 2,
                                 position: 2,
                               })
        QuestionOption.create!({
                                 question: radio_button_question,
                                 text: 'Option 3',
                                 value: 3,
                                 position: 3,
                               })

         QuestionOption.create!({
                                 question: radio_button_question,
                                 text: 'Otro',
                                 value: 4,
                                 position: 4,
                                 other_option: true
                               })

        checkbox_question = FactoryBot.create(:question,
                                              form: f,
                                              form_section: option_elements_section,
                                              text: 'Custom Question Checkboxes',
                                              question_type: 'checkbox',
                                              help_text: 'This is help text for checkboxes.',
                                              position: 5,
                                              answer_field: :answer_05,
                                              is_required: false)
        QuestionOption.create!({
                                 question: checkbox_question,
                                 text: 'Option 1',
                                 value: 1,
                                 position: 1,
                               })
        QuestionOption.create!({
                                 question: checkbox_question,
                                 text: 'Option 2',
                                 value: 2,
                                 position: 2,
                               })
        QuestionOption.create!({
                                 question: checkbox_question,
                                 text: 'Other',
                                 value: 3,
                                 position: 3,
                                 other_option: true
                               })

        dropdown_question = Question.create!({
                                               form: f,
                                               form_section: option_elements_section,
                                               text: 'Custom Question Dropdown',
                                               question_type: 'dropdown',
                                               help_text: 'This is help text for a dropdown.',
                                               position: 6,
                                               answer_field: :answer_06,
                                               is_required: false,
                                             })
        QuestionOption.create!({
                                 question: dropdown_question,
                                 text: 'Option 1',
                                 value: 1,
                                 position: 1,
                               })
        QuestionOption.create!({
                                 question: dropdown_question,
                                 text: 'Option 2',
                                 value: 2,
                                 position: 2,
                               })
        QuestionOption.create!({
                                 question: dropdown_question,
                                 text: 'Option 3',
                                 value: 3,
                                 position: 3,
                               })

        custom_elements_section = f.form_sections.create(title: 'Custom elements', position: 3)
        Question.create!({
                           form: f,
                           form_section: custom_elements_section,
                           text: '<p>Custom text <a href="#">that supports HTML</a> goes here.</p>',
                           question_type: 'text_display',
                           position: 7,
                           answer_field: :answer_15,
                           is_required: false,
                         })

        Question.create!({
                           form: f,
                           form_section: custom_elements_section,
                           text: 'Star radio buttons',
                           question_type: 'star_radio_buttons',
                           position: 8,
                           answer_field: :answer_17,
                           is_required: false,
                         })

        Question.create!({
                  form: f,
                  form_section: custom_elements_section,
                  text: 'hidden value',
                  placeholder_text: 'hidden value',
                  question_type: 'hidden_field',
                  position: 19,
                  answer_field: :answer_19,
                  is_required: false,
                })
      end
    end

    trait :a11 do
      kind { 'a11' }
      after(:create) do |form, _evaluator|

        # Create Page 2
        form.form_sections.create(title: "Page 2", position: 2)

        # Specify the Question Options
        options = {
          "strongly disagree" => "1",
          "disagree" => "2",
          "neutral" => "3",
          "agree" => "4",
          "strongly agree" => "5"
        }

        # Page 1
        question_01 = Question.create!({
          form: form,
          form_section: (form.form_sections.first),
          text: "A-11 Question 1",
          question_type: "radio_buttons",
          position: 1,
          answer_field: :answer_01,
          is_required: true
        })
        question_02 = Question.create!({
          form: form,
          form_section: (form.form_sections.first),
          text: "A-11 Question 2",
          question_type: "radio_buttons",
          position: 2,
          answer_field: :answer_02,
          is_required: true
        })
        question_08 = Question.create!({
          form: form,
          form_section: form.form_sections.first,
          text: "A-11 Question 3",
          question_type: "textarea",
          position: 3,
          answer_field: :answer_08,
        })

        # Page 2
        question_03 = Question.create!({
          form: form,
          form_section: (form.form_sections.last),
          text: "A-11 Question 4",
          question_type: "radio_buttons",
          position: 1,
          answer_field: :answer_03,
        })
        question_04 = Question.create!({
          form: form,
          form_section: (form.form_sections.last),
          text: "A-11 Question 5",
          question_type: "radio_buttons",
          position: 2,
          answer_field: :answer_04,
        })
        question_05 = Question.create!({
          form: form,
          form_section: (form.form_sections.last),
          text: "A-11 Question 6",
          question_type: "radio_buttons",
          position: 3,
          answer_field: :answer_05,
        })
        question_06 = Question.create!({
          form: form,
          form_section: (form.form_sections.last),
          text: "A-11 Question 7",
          question_type: "radio_buttons",
          position: 4,
          answer_field: :answer_06,
        })
        question_07 = Question.create!({
          form: form,
          form_section: (form.form_sections.last),
          text: "A-11 Question 8",
          question_type: "radio_buttons",
          position: 5,
          answer_field: :answer_07,
        })
        question_09 = Question.create!({
          form: form,
          form_section: form.form_sections.last,
          text: "A-11 Question 9",
          question_type: "textarea",
          position: 6,
          answer_field: :answer_09,
        })

        # Create the Question Options for each Radio Button Question
        [
          question_01,
          question_02,
          question_03,
          question_04,
          question_05,
          question_06,
          question_07,
        ].each do |q|
          options.each_with_index do |(option, value), j|
            QuestionOption.create!({
              question: q,
              text: option,
              value: value,
              position: j + 1
            })
          end
        end
      end

    end

    trait :a11_v2 do
      name { 'Version 2 of the A11 form' }
      kind { 'a11_v2' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          question_type: 'big_thumbs_up_down_buttons',
                          form_section: f.form_sections.first,
                          text: 'Please rate your experience as a customer of Agency of Departments.',
                          position: 1,
                          is_required: true,
                          )
        FactoryBot.create(:question,
                          :with_a11_v2_checkbox_options,
                          form: f,
                          answer_field: :answer_02,
                          form_section: f.form_sections.first,
                          text: 'Positive indicators',
                          position: 2,
                          )
        FactoryBot.create(:question,
                          :with_a11_v2_checkbox_options,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first,
                          text: 'Negative indicators',
                          position: 3
                          )
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_04,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Additional comments',
                          position: 4
                          )
      end
    end

    trait :a11_v2_radio do
      name { 'Version 2 of the A11 form (Radio Buttons)' }
      kind { 'a11_v2_radio' }
      after(:create) do |f, _evaluator|
        question_1_radio_buttons = FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          question_type: 'radio_buttons',
                          form_section: f.form_sections.first,
                          text: 'Please rate your experience as a customer of Agency of Departments.',
                          position: 1,
                          is_required: true,
                          )
        FactoryBot.create(:question,
                          :with_a11_v2_checkbox_options,
                          form: f,
                          answer_field: :answer_02,
                          form_section: f.form_sections.first,
                          text: 'Positive indicators',
                          position: 2,
                          )
        FactoryBot.create(:question,
                          :with_a11_v2_checkbox_options,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first,
                          text: 'Negative indicators',
                          position: 3
                          )
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_04,
                          question_type: 'textarea',
                          form_section: f.form_sections.first,
                          text: 'Additional comments',
                          position: 4
                          )

        QuestionOption.create!({
          question: question_1_radio_buttons,
          text: 'Strongly disagree',
          value: 1,
          position: 1,
        })
        QuestionOption.create!({
          question: question_1_radio_buttons,
          text: 'Disagree',
          value: 2,
          position: 2,
        })
        QuestionOption.create!({
          question: question_1_radio_buttons,
          text: 'Neutral',
          value: 3,
          position: 3,
        })
        QuestionOption.create!({
          question: question_1_radio_buttons,
          text: 'Agree',
          value: 4,
          position: 4,
        })
        QuestionOption.create!({
          question: question_1_radio_buttons,
          text: 'Strongly agree',
          value: 5,
          position: 5,
        })
      end
    end

    trait :checkbox_form do
      name { 'Checkbox form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :with_checkbox_options,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first)
      end
    end

    trait :phone do
      name { 'Phone text form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :phone,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first)
      end
    end

    trait :email do
      name { 'Email text form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :email,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first)
      end
    end

    trait :radio_button_form do
      name { 'Radio button form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :with_radio_buttons,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first)
      end
    end

    trait :states_dropdown_form do
      name { 'States dropdown form' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :states_dropdown,
                          form: f,
                          answer_field: :answer_03,
                          form_section: f.form_sections.first,
                          text: 'Name')
      end
    end

    trait :big_thumbs do
      name { 'Big Thumbs Up/Down' }
      kind { 'custom' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          :big_thumbs_up_down_buttons,
                          form: f,
                          answer_field: :answer_01,
                          form_section: f.form_sections.first,
                          text: 'Did you find this page useful?')
      end
    end

    trait :yes_no_buttons do
      name { 'Yes/No buttons form' }
      kind { 'custom' }
      delivery_method { 'inline' }
      element_selector { 'touchpoint-goes-here' }
      after(:create) do |f, _evaluator|
        FactoryBot.create(:question,
                          form: f,
                          answer_field: :answer_01,
                          question_type: 'yes_no_buttons',
                          form_section: f.form_sections.first,
                          is_required: true,
                          text: 'Was this page useful?')
      end
    end
  end
end
