# frozen_string_literal: true

require 'rails_helper'

feature 'Example Website Integration', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:open_ended_form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
  let(:recruiter_form) { FactoryBot.create(:form, :recruiter, organization:, user: admin) }

  describe 'third-party .gov website' do
    before do
      login_as(admin)
    end

    context 'Open-ended Touchpoint' do
      before do
        visit example_admin_form_path(open_ended_form)
      end

      it 'loads Badge with Text' do
        expect(page).to have_content('Help improve this site')
      end

      describe 'clicking the Feedback Form tab' do
        before do
          click_on 'fba-button'
        end

        describe 'standard Modal' do
          it 'opens the modal' do
            expect(page).to have_css('.touchpoints-form-wrapper', visible: true)
            within '.touchpoints-form-wrapper' do
              expect(page).to have_content open_ended_form.title
            end
          end

          it 'close the modal' do
            find('.fba-modal-close').click
            expect(page).to_not have_css('.fba-modal')
          end
        end

        describe 'submit the form' do
          before 'fill-in the form' do
            fill_in 'answer_01', with: 'All my open-ended concerns.'
            click_button 'Submit'
          end

          it 'display .js success alert' do
            expect(page.find('.fba-alert')).to have_content('Thank you. Your feedback has been received.')
          end
        end
      end
    end

    context 'Recruiter Touchpoint' do
      before do
        visit example_admin_form_path(recruiter_form)
      end

      it 'loads Badge with Text' do
        expect(page).to have_content('Help improve this site')
      end

      describe 'clicking the Feedback Form tab' do
        before do
          click_on 'fba-button'
        end

        it 'opens Modal' do
          expect(page).to have_css('.touchpoints-form-wrapper', visible: true)

          within '.touchpoints-form-wrapper' do
            expect(page).to have_content 'Do you have a few minutes to help us test this site?'
          end
        end

        describe 'submit the form' do
          before 'fill-in the form' do
            fill_in 'answer_01', with: 'Concerned Citizen'
            fill_in 'answer_02', with: 'test_public_user@example.com'
            fill_in 'answer_03', with: '555-123-4567'
            click_button 'Submit'
          end

          it 'display .js success alert' do
            expect(page.find('.fba-alert')).to have_content('Thank you. Your feedback has been received.')
          end
        end
      end
    end

    context 'Yes/No Buttons' do
      let(:yes_no_buttons_form) { FactoryBot.create(:form, :yes_no_buttons, organization:, user: admin) }

      before do
        visit example_admin_form_path(yes_no_buttons_form)
      end

      it 'loads the form inline' do
        expect(page).to have_content('Do you have a few minutes to help us test this site?')
        expect(page).to have_content('Was this page useful?')
      end

      describe 'submits `Yes`' do
        before do
          click_on 'yes'
        end

        it 'display success message' do
          expect(page).to have_content('Thank you. Your feedback has been received.')
          expect(yes_no_buttons_form.submissions.first.answer_01).to eq('yes')
        end
      end

      describe 'submits `No`' do
        before do
          click_on 'no'
        end

        it 'display success message' do
          expect(page).to have_content('Thank you. Your feedback has been received.')
          expect(yes_no_buttons_form.submissions.first.answer_01).to eq('no')
        end
      end
    end
  end
end
