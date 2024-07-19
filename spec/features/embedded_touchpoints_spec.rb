# frozen_string_literal: true

require 'rails_helper'

feature 'Touchpoints', js: true do
  let(:organization) { FactoryBot.create(:organization) }

  context 'as Admin' do
    let!(:user) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :kitchen_sink, organization:) }

    describe '/forms/:id/example' do
      before do
        login_as(user)
      end

      context 'default success text' do
        before do
          visit example_admin_form_path(form)
          click_on('Help improve this site') # opens modal
          expect(page).to have_content('Help improve this site')

          expect(page).to have_content('Do you have a few minutes to help us test this site?')
          fill_in 'answer_01', with: 'input field'
          fill_in 'answer_02', with: 'email'
          fill_in 'answer_03', with: 'textarea'

          click_on 'Next'
          expect(page).to have_content('Please enter a valid value')
          expect(page).to have_content('This is help text')

          fill_in 'answer_02', with: 'email@example.gov'
          click_on 'Next'

          expect(page).to have_content('Option elements')
          expect(all("##{form.questions[3].ui_selector} .usa-radio__label").size).to eq(4)
          all("##{form.questions[3].ui_selector} .usa-radio__label").last.click
          fill_in("#{form.questions[3].ui_selector}_other", with: 'otro 2')

          all('.usa-checkbox__label').each(&:click)
          # fill_in("question_#{form.questions[4].id}_answer_05_other", with: 'other 3')
          fill_in("#{form.questions[4].ui_selector}_other", with: 'other 3')
          select('Option 2', from: 'answer_06')
          click_on 'Next'
          expect(page).to have_content('Custom elements')
          find('.submit_form_button').click

          # shows success flash message
          expect(page).to have_content('Success')
          expect(page).to have_content('Thank you. Your feedback has been received.')

          # doesn't reset form; leave the flash message
          find(".fba-modal-close").click
          find("#fba-button").click
          expect(page).to have_content('Thank you. Your feedback has been received.')
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
