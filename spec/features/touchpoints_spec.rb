# frozen_string_literal: true

require 'rails_helper'

feature 'Touchpoints', js: true do
  let(:organization) { FactoryBot.create(:organization) }

  context 'as Admin' do
    let!(:user) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

    describe '/touchpoints' do
      before do
        form.update_attribute(:verify_csrf, true)
        form.reload
      end

      context 'default success text' do
        before do
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime('%m/%d/%Y')}")
          fill_in('answer_01', with: 'User feedback')
          click_button 'Submit'
        end

        describe 'display default success text' do
          it 'renders success flash message' do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on
          end
        end
      end

      context 'SPAMBOT' do
        before do
          visit touchpoint_path(form)
          page.execute_script("document.getElementById('fba_directive').value = 'SPAM Text'")
          click_button 'Submit'
        end

        it 'fails the submission' do
          expect(page).to have_content('this submission was not successful')
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on
        end
      end

      context 'form.verify_csrf=true, but with invalid authenticity_token' do
         before do
          expect(form.verify_csrf).to be true
          visit touchpoint_path(form)
          page.execute_script("document.getElementById('authenticity_token').value = 'an invalid csrf token'")
          click_button 'Submit'
        end

        it 'fails the submission' do
          expect(page).to have_content('Error')
          expect(page).to have_content('submission invalid CSRF authenticity token')
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
        end
      end

      context 'form.verify_csrf=true, but without authenticity_token' do
         before do
          expect(form.verify_csrf).to be true
          visit touchpoint_path(form)
          page.execute_script("document.getElementById('authenticity_token').remove()")
          expect(page).to_not have_css("#authenticity_token", visible: false)
          click_button 'Submit'
        end

        it 'fails the submission' do
          expect(page).to have_content('Error')
          expect(page).to have_content('submission invalid CSRF authenticity token')
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
        end
      end

      context 'form.verify_csrf=false' do
         before do
          form.update!(verify_csrf: false)
          expect(form.verify_csrf).to be false

          visit touchpoint_path(form)
          expect(page).to_not have_css("#authenticity_token", visible: false)
          click_button 'Submit'
        end

        it 'successful submission' do
          expect(page).to have_content('Success')
          expect(page).to have_content('Thank you. Your feedback has been received.')
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
        end
      end

      context 'custom success text' do
        before do
          form.update(success_text: "Much success. \n With a second line.")
          form.reload
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime('%m/%d/%Y')}")
          fill_in('answer_01', with: 'User feedback')
          click_button 'Submit'
        end

        describe 'display custom success text' do
          it 'renders success flash message' do
            expect(page).to have_text(form.success_text.gsub("\n ", '')) # convert the line break and following space to html text
            expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
          end
        end
      end

      context 'custom HTML success text' do
        before do
          form.update(success_text: "Much success. \n With a <a href='#'>Link</a>.")
          form.reload
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          fill_in('answer_01', with: 'User feedback')
          click_button 'Submit'
        end

        describe 'display custom HTML success text' do
          it 'renders success flash message' do
            expect(page).to have_text('Much success. With a Link.')
            expect(page).to have_link('Link')
            expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
          end
        end
      end
    end

    describe 'checkbox question' do
      let!(:checkbox_form) { FactoryBot.create(:form, :checkbox_form, organization:) }

      before do
        visit touchpoint_path(checkbox_form)
        all('.usa-checkbox__label').each(&:click)
        click_on 'Submit'
      end

      it 'persists checkbox question values to db as comma separated list' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        expect(Submission.last.answer_03).to eq 'One,Two,Three,Four'
      end

      context "with an question option of 'other'" do
        before do
          checkbox_form.questions.first.question_options.create!(text: 'other', position: 5)
          checkbox_form.questions.first.question_options.create!(text: 'otro', position: 6)
          visit touchpoint_path(checkbox_form)
        end

        context "default 'other' value" do
          before do
            all('.usa-checkbox__label').each(&:click)
            click_on 'Submit'
          end

          it "persists 'other' checkbox question default values to db as comma separated list" do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(Submission.last.answer_03).to eq 'One,Two,Three,Four,other,otro'
          end
        end

        context "user-entered 'other' value" do
          before do
            all('.usa-checkbox__label').each(&:click)
            inputs = find_all('input')
            inputs.first.set('hi')
            inputs.last.set('bye')
            click_on 'Submit'
          end

          it "persists 'other' checkbox question custom values to db as comma separated list" do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(Submission.last.answer_03).to eq 'One,Two,Three,Four,hi,bye'
          end
        end
      end
    end

    describe 'radio buttons question' do
      let!(:radio_button_form) { FactoryBot.create(:form, :radio_button_form, organization:) }
      let!(:last_radio_option) { radio_button_form.questions.first.question_options.create!(text: 'other', value: 'other', position: 6) }

      before do
        visit touchpoint_path(radio_button_form)
        all('.usa-radio__label').each(&:click)
        click_on 'Submit'
      end

      it 'persists radio button question values to db' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        # implicitly test radio options
        expect(Submission.last.answer_03).to eq last_radio_option.value
        # explicitly test that the default "other" value works (separately from the input box)
        expect(Submission.last.answer_03).to eq 'other'
      end

      context "with an question option of 'other'" do
        context "user-entered 'other' value" do
          before do
            visit touchpoint_path(radio_button_form)
            all('.usa-radio__label').each(&:click)

            inputs = find_all('input')
            inputs.first.set('hi')
            inputs.last.set('bye')
            click_on 'Submit'
          end

          it "persists 'other' checkbox question custom values to db as comma separated list" do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(Submission.last.answer_03).to eq 'bye'
          end
        end
      end
    end

    describe 'states dropdown question' do
      let!(:dropdown_form) { FactoryBot.create(:form, :states_dropdown_form, organization:) }

      before do
        visit touchpoint_path(dropdown_form)
        select('CA', from: 'answer_03')
        click_on 'Submit'
      end

      it 'persists question values to db' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        expect(Submission.last.answer_03).to eq 'CA'
      end

      context 'when required' do
        before do
          dropdown_form.questions.first.update(is_required: true)
          visit touchpoint_path(dropdown_form)
        end

        it 'display flash message' do
          click_on 'Submit'
          expect(page).to have_content('A response is required:')
        end
      end
    end

    describe 'phone number question' do
      let!(:phone_form) { FactoryBot.create(:form, organization:) }
      let!(:phone_question) { FactoryBot.create(:question, :phone, form: phone_form, form_section: phone_form.form_sections.first) }

      before do
        visit touchpoint_path(phone_form)
      end

      it 'not-successful, less than 10 digit phone number' do
        fill_in("question_#{phone_question.id}_answer_01", with: "123456789")
        click_on 'Submit'
        expect(page).to have_content("Please enter a valid value: Phone Number")
      end

      it 'successful, 10 digit phone number' do
        fill_in("question_#{phone_question.id}_answer_01", with: "1234567890")
        click_on 'Submit'
        expect(page).to have_content("Thank you. Your feedback has been received.")
      end
    end

    describe 'multi-page early submission form' do
      let!(:multi_form) { FactoryBot.create(:form, :kitchen_sink, organization:) }

      context 'when required on 2nd page' do
        before do
          multi_form.update(early_submission: true)
          multi_form.form_sections[1].questions.first.update(is_required: true)
          visit touchpoint_path(multi_form)
        end

        it 'display flash message' do
          click_on 'No, only submit these responses'
          expect(page).to have_content('A response is required:')
        end
      end
    end

    describe 'phone number question' do
      let!(:dropdown_form) { FactoryBot.create(:form, :phone, organization:) }

      before do
        visit touchpoint_path(dropdown_form)
      end

      it 'allows numeric input and a maximum of 10 numbers' do
        fill_in dropdown_form.ordered_questions.last.id, with: '12345678901234'
        expect(find("#question_#{dropdown_form.ordered_questions.last.id}_answer_03").value).to eq('(123) 456-7890')
      end

      it 'disallows text input' do
        fill_in dropdown_form.ordered_questions.last.id, with: 'abc'
        expect(find("##{dropdown_form.ordered_questions.last.id}").value).to eq('')
      end
    end

    describe 'date select question' do
      let!(:date_select_form) { FactoryBot.create(:form, :date_select, organization:) }

      before do
        visit touchpoint_path(date_select_form)
      end

      it 'allows a valid date string' do
        fill_in date_select_form.ordered_questions.last.ui_selector, with: '10/04/2021'
        click_on 'Submit'
        expect(page).not_to have_content('Please enter a valid value')
      end

      it 'disallows non date input' do
        fill_in date_select_form.ordered_questions.last.ui_selector, with: 'abc'
        click_on 'Submit'
        expect(page).to have_content('Please enter a valid value')
      end
    end

    describe 'hidden_field question' do
      let!(:hidden_field_form) { FactoryBot.create(:form, :hidden_field_form, organization:) }

      context 'render' do
        before do
          visit submit_touchpoint_path(hidden_field_form)
        end

        it 'generates hidden field' do
          expect(find("##{hidden_field_form.ordered_questions.last.ui_selector}", visible: false).value).to eq('hidden value')
        end
      end

      context 'submit' do
        before do
          visit touchpoint_path(hidden_field_form)
          click_button 'Submit'
        end

        it 'persists the hidden field' do
          expect(page).to have_content('Thank you. Your feedback has been received.')
          expect(Submission.last.answer_01).to eq 'hidden value'
        end
      end
    end

    describe 'email question' do
      let!(:dropdown_form) { FactoryBot.create(:form, :email, organization:) }

      before do
        visit touchpoint_path(dropdown_form)
      end

      it 'allows valid email address' do
        fill_in dropdown_form.ordered_questions.last.ui_selector, with: 'test@test.com'
        click_button 'Submit'
        expect(page).to have_content('Thank you. Your feedback has been received.')
      end

      it 'disallows invalid text input' do
        fill_in dropdown_form.ordered_questions.last.ui_selector, with: 'test@testcom'
        click_button 'Submit'
        expect(page).to have_content('Please enter a valid value: Email')
      end
    end

    describe 'required question' do
      before do
        form.questions.first.update(is_required: true)
        visit touchpoint_path(form)
        click_on 'Submit'
      end

      it 'displays an error message' do
        expect(page).to have_content('A response is required: Test Open Area')
      end

      it 'regression: does not display invisible error message inputs' do
        expect(page).to have_no_css('input#fba_directive', visible: true)
      end

      it 'can successfully submit after completing the required question' do
        fill_in(form.ordered_questions.first.ui_selector, with: 'a response to this required question')
        find('.submit_form_button').click
        expect(page).to have_content('Thank you. Your feedback has been received.')
      end
    end

    context 'character_limit' do
      describe 'without character_limit' do
        before do
          question = form.questions.first
          visit touchpoint_path(form)
        end

        it 'does not display character count messaging' do
          expect(page).to_not have_content('characters')
          expect(page).to_not have_content('allowed')
        end
      end

      describe 'with character_limit' do
        before do
          question = form.questions.first
          question.update(character_limit: 150)
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime('%m/%d/%Y')}")
          fill_in(form.ordered_questions.first.ui_selector, with: 'T' * 145)
        end

        it 'updates character count' do
          expect(page).to have_content('5 characters left')
        end
      end
    end

    describe '/touchpoints?location_code=' do
      before do
        visit submit_touchpoint_path(form, location_code: 'TEST_LOCATION_CODE')
        fill_in(form.ordered_questions.first.ui_selector, with: 'User feedback')
        click_button 'Submit'
      end

      describe '#show' do
        it 'renders success flash message and persists location_code' do
          expect(page).to have_content('Thank you. Your feedback has been received.')
          expect(page).to have_current_path("/touchpoints/#{form.short_uuid}/submit?location_code=TEST_LOCATION_CODE") # stays on same page after form submission

          # Asserting against the database/model directly here isn't ideal.
          # An alternative is to send location_code back to the client and assert against it
          expect(Submission.last.location_code).to eq 'TEST_LOCATION_CODE'
        end
      end
    end

    describe 'A-11 Version 2 Form' do
      let!(:custom_form) { FactoryBot.create(:form, :a11_v2, organization:) }

      before do
        visit submit_touchpoint_path(custom_form)
        find("label[for='#{custom_form.ordered_questions.first.ui_selector}_star4']").click
        fill_in(custom_form.ordered_questions.last.ui_selector, with: 'User feedback')
        click_button 'Submit'
      end

      it 'submits successfully' do
        expect(page).to have_content('Thank you. Your feedback has been received.')

        # Asserting against the database/model directly here isn't ideal.
        # An alternative is to send location_code back to the client and assert against it
        last_submission = Submission.last
        expect(last_submission.answer_01).to eq '4'
        # expect(last_submission.answer_02).to eq "TEST_LOCATION_CODE"
        expect(last_submission.answer_03).to eq 'User feedback'
      end
    end

    describe 'Multiple Star Ratings Form' do
      let!(:custom_form) { FactoryBot.create(:form, :star_ratings, organization:) }

      before do
        visit submit_touchpoint_path(custom_form)
        find("label[for='question_#{custom_form.ordered_questions.first.id}_answer_01_star1']").click
        find("label[for='question_#{custom_form.ordered_questions.second.id}_answer_02_star2']").click
        find("label[for='question_#{custom_form.ordered_questions.third.id}_answer_03_star3']").click
        click_button 'Submit'
      end

      it 'can save form values for each star rating question' do
        expect(page).to have_content('Thank you. Your feedback has been received.')

        # Asserting against the database/model directly here isn't ideal.
        # An alternative is to send location_code back to the client and assert against it
        last_submission = Submission.last
        expect(last_submission.answer_01).to eq '1'
        expect(last_submission.answer_02).to eq '2'
        expect(last_submission.answer_03).to eq '3'
      end
    end
  end

  context 'as public user' do
    let!(:admin) { FactoryBot.create(:user, :admin, organization:) }

    describe '/touchpoints' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, aasm_state: 'created') }

      context 'for a created form' do
        before do
          visit touchpoint_path(form)
        end

        it 'redirect to index and display a flash message' do
          expect(page).to have_content('Form is not currently deployed.')
          expect(page.current_path).to eq(index_path)
        end
      end
    end

    describe '/touchpoints' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, aasm_state: 'archived') }

      context 'for an archived form' do
        before do
          visit touchpoint_path(form)
        end

        it 'render archived/inactive message' do
          expect(page).to have_content('This form is not currently accepting feedback')
          expect(page).to have_content(form.title)
          expect(page.current_path).to eq(submit_touchpoint_path(form))
        end
      end
    end

    describe '/touchpoints' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, aasm_state: 'published') }

      context 'for a live form' do
        before do
          visit touchpoint_path(form)
        end

        it 'render the form' do
          expect(page).to have_css('.touchpoint-form')
          expect(page).to have_content(form.title)
        end
      end
    end
  end
end
