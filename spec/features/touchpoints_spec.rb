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

      it 'is accessible' do
        visit touchpoint_path(form)
        expect(page).to be_axe_clean
      end

      describe 'persist text responses in localStorage' do
        let(:two_question_form) { FactoryBot.create(:form, :two_question_open_ended_form, organization:) }

        before do
          visit touchpoint_path(two_question_form)
          fill_in(two_question_form.ordered_questions.first.ui_selector, with: 'Question one')
          fill_in(two_question_form.ordered_questions.last.ui_selector, with: 'Question two')
          visit touchpoint_path(two_question_form)
        end

        it "enters text, refreshes to ensure it still there, submits, and ensures it has been cleared" do
          expect(find("#" + two_question_form.ordered_questions.first.ui_selector).value).to eq('Question one')
          expect(find("#" + two_question_form.ordered_questions.last.ui_selector).value).to eq('Question two')
          click_button 'Submit'
          expect(page).to have_content('Thank you. Your feedback has been received.')
          visit touchpoint_path(two_question_form)
          expect(find("#" + two_question_form.ordered_questions.first.ui_selector).value).to be_blank
          expect(find("#" + two_question_form.ordered_questions.last.ui_selector).value).to be_blank
        end
      end

      context 'default success text' do
        before do
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime('%m/%d/%Y')}")
          fill_in(form.ordered_questions.last.ui_selector, with: 'User feedback')
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

      describe 'form title' do
        context 'when the title has text, is not blank' do
          before do
            visit touchpoint_path(form)
          end

          it 'displays the form title in an h1' do
            within("h1") do
              expect(page).to have_text(form.title)
            end
          end
        end

        context 'with blank/empty form title' do
          before do
            form.update(title: "")
            visit touchpoint_path(form)
          end

          it 'in h1 does not render a title but does render text for screen reader' do
            expect(find("h1").text).to be_empty
            expect(page).to have_css('h1 .usa-sr-only', text: 'Feedback form', visible: :all)
          end
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
          fill_in(form.ordered_questions.last.ui_selector, with: 'User feedback')
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
          fill_in(form.ordered_questions.last.ui_selector, with: 'User feedback')
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
        expect(Submission.ordered.first.answer_03).to eq 'One,Two,Three,Four'
      end

      context "with a question option of 'other'" do
        before do
          checkbox_form.questions.first.question_options.create!(text: 'other', position: 5, other_option: true)
          visit touchpoint_path(checkbox_form)
        end

        context "default 'other' value" do
          before do
            all('.usa-checkbox__label').each(&:click)
            click_on 'Submit'
          end

          it "persists 'other' checkbox question default values to db as comma separated list" do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(Submission.ordered.first.answer_03).to eq 'One,Two,Three,Four,other'
          end
        end

        context "user-entered 'other' value" do
          before do
            all('.usa-checkbox__label').each(&:click)
            inputs = find_all('input')
            inputs.last.set('hi')
            click_on 'Submit'
          end

          it "persists 'other' checkbox question custom values to db as comma separated list" do
            expect(page).to have_content('Thank you. Your feedback has been received.')
            expect(Submission.ordered.first.answer_03).to eq 'One,Two,Three,Four,hi'
          end
        end
      end
    end

    describe 'radio buttons question' do
      let!(:radio_button_form) { FactoryBot.create(:form, :radio_button_form, organization:) }
      let!(:last_radio_option) { radio_button_form.questions.first.question_options.create!(text: 'other', value: 'other', position: 6, other_option: true) }

      before do
        visit touchpoint_path(radio_button_form)
        all('.usa-radio__label').each(&:click)
        click_on 'Submit'
      end

      it 'persists radio button question values to db' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        # implicitly test radio options
        expect(Submission.ordered.first.answer_03).to eq last_radio_option.value
        # explicitly test that the default "other" value works (separately from the input box)
        expect(Submission.ordered.first.answer_03).to eq 'other'
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
            expect(Submission.ordered.first.answer_03).to eq 'bye'
          end
        end
      end
    end

    describe 'rich text question' do
      let(:rich_text_form) { FactoryBot.create(:form, organization:) }
      let!(:rich_text_question_1) { FactoryBot.create(:question, form: rich_text_form, position: 1, form_section: rich_text_form.form_sections.first, question_type: "rich_textarea", answer_field: 'answer_01', text: "Q1" ) }
      let!(:rich_text_question_2) { FactoryBot.create(:question, form: rich_text_form, position: 2, form_section: rich_text_form.form_sections.first, question_type: "rich_textarea", answer_field: 'answer_02', text: "Q2", is_required: true) }
      let!(:rich_text_question_3) { FactoryBot.create(:question, form: rich_text_form, position: 3, form_section: rich_text_form.form_sections.first,  question_type: "rich_textarea", answer_field: 'answer_03', text: "Q3", character_limit: 300) }

      before do
        visit touchpoint_path(rich_text_form)
        find("##{rich_text_question_1.ui_selector} .ql-editor").send_keys("some text goes here")
        find("##{rich_text_question_2.ui_selector}").click
      end

      it 'persists rich text values from localStorage' do
        expect(find("#hidden-#{rich_text_question_1.ui_selector}", visible: false).value).to eq("<p>some text goes here</p>")
        visit touchpoint_path(rich_text_form)
        expect(find("#hidden-#{rich_text_question_1.ui_selector}", visible: false).value).to eq("<p>some text goes here</p>")
        find("##{rich_text_question_3.ui_selector} .ql-editor").send_keys("some more text goes here")
        expect(page).to have_content("269 characters left")
        click_on "Submit"
        expect(page).to have_content("A response is required: Q2")
        find("##{rich_text_question_2.ui_selector} .ql-editor").send_keys("okay now")
        click_on "Submit"
        expect(page).to have_content("Thank you. Your feedback has been received.")
      end
    end

    describe 'states dropdown question' do
      let!(:dropdown_form) { FactoryBot.create(:form, :states_dropdown_form, organization:) }

      before do
        visit touchpoint_path(dropdown_form)
        select('CA', from: dropdown_form.ordered_questions.last.ui_selector)
        click_on 'Submit'
      end

      it 'persists question values to db' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        expect(Submission.ordered.first.answer_03).to eq 'CA'
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
        fill_in dropdown_form.ordered_questions.last.ui_selector, with: '12345678901234'
        expect(find("##{dropdown_form.ordered_questions.last.ui_selector}").value).to eq('(123) 456-7890')
      end

      it 'disallows text input' do
        fill_in dropdown_form.ordered_questions.last.ui_selector, with: 'abc'
        expect(find("##{dropdown_form.ordered_questions.last.ui_selector}").value).to eq('')
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
          expect(Submission.ordered.first.answer_01).to eq 'hidden value'
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
          latest_submission = Submission.ordered.first
          expect(latest_submission.location_code).to eq('TEST_LOCATION_CODE')
          expect(latest_submission.query_string).to eq("?location_code=TEST_LOCATION_CODE")
        end
      end
    end

    describe 'A-11 Version 2 Form (Thumbs up/down)' do
      let!(:a11_v2_form) { FactoryBot.create(:form, :a11_v2, organization:) }

      before do
        visit submit_touchpoint_path(a11_v2_form)
      end

      it 'submits successfully' do
        expect(page).to have_content(a11_v2_form.title)
        expect(page).to have_content("This is help text.")
        find("svg[aria-labelledby='thumbs-up-icon']").click # the thumbs up
        expect(page).to have_content("Positive indicators")
        expect(page).to have_content("effectiveness")
        expect(page).to have_content("ease")
        expect(page).to have_content("efficiency")
        expect(page).to have_content("transparency")
        find("label[for='question_option_1']").click
        find("label[for='question_option_4']").click
        click_button 'Submit'
        expect(page).to have_content('Thank you. Your feedback has been received.')

        latest_submission = Submission.ordered.first
        expect(latest_submission.answer_01).to eq '1'
        expect(latest_submission.answer_02).to eq 'effectiveness,transparency'
        expect(latest_submission.answer_03).to eq ""
        expect(latest_submission.answer_04).to eq ""
      end
    end

    describe 'A-11 Version 2 (Radio Button) Form' do
      let!(:a11_v2_radio_form) { FactoryBot.create(:form, :a11_v2_radio, organization:) }

      before do
        visit submit_touchpoint_path(a11_v2_radio_form)
      end

      it 'toggles positive and negative indicators and submits successfully' do
        expect(page).to have_content(a11_v2_radio_form.title)
        expect(page).to_not have_content("Negative indicators")
        expect(page).to_not have_content("Positive indicators")

        find_all("label")[0].click # option 1
        expect(page).to have_content("Negative indicators")

        find_all("label")[3].click # option 4
        expect(page).to have_content("Positive indicators")

        find_all("label")[1].click # option 2
        expect(page).to have_content("Negative indicators")

        find_all("label")[4].click # option 5
        expect(page).to have_content("Positive indicators")

        find_all("label")[2].click # option 3
        expect(page).to have_content("Negative indicators")

        expect(page).to have_content("This is help text.")
        expect(page).to have_content("effectiveness")
        expect(page).to have_content("ease")
        expect(page).to have_content("efficiency")
        expect(page).to have_content("transparency")

        click_button 'Submit'
        expect(page).to have_content('Thank you. Your feedback has been received.')

        latest_submission = Submission.ordered.first
        expect(latest_submission.answer_01).to eq '3'
        expect(latest_submission.answer_02).to eq nil
        expect(latest_submission.answer_03).to eq nil
        expect(latest_submission.answer_04).to eq ""
      end
    end

    describe 'Big Thumbs' do
      let!(:custom_form) { FactoryBot.create(:form, :big_thumbs, organization:) }

      before do
        visit submit_touchpoint_path(custom_form)
        expect(page).to have_content("This is help text.")
        find("label[for='question_option_2_yes']").click
        click_button 'Submit'
      end

      it 'submits successfully' do
        expect(page).to have_content('Thank you. Your feedback has been received.')
        latest_submission = Submission.ordered.first
        expect(latest_submission.answer_01).to eq '1'
      end
    end

    describe 'Multiple Star Ratings Form' do
      let!(:custom_form) { FactoryBot.create(:form, :star_ratings, organization:) }

      before do
        visit submit_touchpoint_path(custom_form)
        find("label[for='#{custom_form.ordered_questions.first.ui_selector}_star1']").click
        find("label[for='#{custom_form.ordered_questions.second.ui_selector}_star2']").click
        find("label[for='#{custom_form.ordered_questions.third.ui_selector}_star3']").click
        click_button 'Submit'
      end

      it 'can save form values for each star rating question' do
        expect(page).to have_content('Thank you. Your feedback has been received.')

        # Asserting against the database/model directly here isn't ideal.
        # An alternative is to send location_code back to the client and assert against it
        latest_submission = Submission.ordered.first
        expect(latest_submission.answer_01).to eq '1'
        expect(latest_submission.answer_02).to eq '2'
        expect(latest_submission.answer_03).to eq '3'
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
