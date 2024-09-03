# frozen_string_literal: true

require 'rails_helper'

feature 'Touchpoints', js: true do
  let(:organization) { FactoryBot.create(:organization) }

  [true, false].each do |val|
    context "as Admin with legacy_form_embed #{val}" do
      let!(:user) { FactoryBot.create(:user, :admin, organization:) }
      let!(:form) { FactoryBot.create(:form, :kitchen_sink, legacy_form_embed: val, organization:) }

      describe '/forms/:id/example' do
        before do
          login_as(user)
          visit example_admin_form_path(form)
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        context 'default success text' do
          before do
            expect(page).to have_content("main content")
            click_on('Help improve this site') # opens modal

            expect(page).to have_content('Help improve this site')
            expect(page).to have_content('Do you have a few minutes to help us test this site?')

            within(".fba-modal") do
              expect(page).to have_content('Page 1')
              expect(page).to have_no_content('Option elements')
              expect(page).to have_no_content('Custom elements')
              fill_in form.ordered_questions.first.ui_selector, with: 'input field'
              fill_in form.ordered_questions.second.ui_selector, with: 'email'
              fill_in form.ordered_questions.third.ui_selector, with: 'textarea'
              expect(page).to have_link('html')

              find(".pagination-buttons.text-right", visible: true).click_link("Next")
              expect(page).to have_content('Please enter a valid value')
              expect(page).to have_content('This is help text')
              fill_in form.ordered_questions.second.ui_selector, with: 'email@example.gov'

              find(".pagination-buttons.text-right", visible: true).click_link("Next")

              expect(page).to have_content('Option elements')
              expect(page).to have_no_content('Page 1')
              expect(page).to have_no_content('Custom elements')
              expect(all("#question_#{form.ordered_questions[4].id} .usa-radio__label").size).to eq(3)
              all("#question_#{form.ordered_questions[4].id} .usa-radio__label").last.click
              fill_in("#{form.ordered_questions[4].ui_selector}_other", with: 'otro 2')

              expect(page).to have_content("Custom Question Checkboxes")
              expect(page).to have_content("This is help text for checkboxes")
              all('.usa-checkbox__label').each(&:click)
              expect(page).to have_content("Enter other text")

              expect(page).to have_css("##{form.ordered_questions[5].ui_selector}_other")
              fill_in("#{form.ordered_questions[5].ui_selector}_other", with: 'other 3')
              find("##{form.ordered_questions[5].ui_selector}_other", visible: true).native.send_key :tab

              expect(page).to have_content("This is help text for a dropdown.")
              select('Option 2', from: form.ordered_questions[6].ui_selector)
              find(".pagination-buttons.text-right", visible: true).click_link("Next")
              expect(page).to have_content('Custom elements')
              expect(page).to have_no_content('Page 1')
              expect(page).to have_no_content('Option elements')
              find('.submit_form_button').click

              # shows success flash message
              expect(page).to have_content('Success')
              expect(page).to have_content('Thank you. Your feedback has been received.')

              # doesn't reset form; leave the flash message
              find(".fba-modal-close").click
              find("#fba-button").click
              expect(page).to have_content('Thank you. Your feedback has been received.')
            end
          end

          it 'renders success flash message' do
            @submission = Submission.last
            expect(@submission.answer_01).to eq('input field')
            expect(@submission.answer_02).to eq('email@example.gov')
            expect(@submission.answer_03).to eq('textarea')
            expect(@submission.answer_04).to eq('otro 2')
            expect(@submission.answer_05).to eq('1,2,other 3')
            expect(@submission.answer_06).to eq('2')
          end
        end
      end
    end
  end
end
