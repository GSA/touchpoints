# frozen_string_literal: true

require 'rails_helper'

feature 'Forms', js: true do
  let(:future_date) do
    3.days.from_now
  end
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  context 'as Admin' do
    before do
      login_as(admin)
    end

    describe '/admin/forms' do
      let!(:form) { FactoryBot.create(:form, organization:) }
      let!(:form2) { FactoryBot.create(:form, organization:) }
      let!(:form3) { FactoryBot.create(:form, organization:) }
      let!(:form4) { FactoryBot.create(:form, organization:, aasm_state: :submitted) }
      let!(:form5) { FactoryBot.create(:form, organization:, aasm_state: :archived) }

      before do
        visit admin_forms_path
      end

      it "displays 3 published forms" do
        expect(page).to have_content("PUBLISHED")
        expect(page).to_not have_content("ARCHIVED")
        expect(find_all(".usa-table tbody tr").size).to eq(3)
      end

      context "use the visible buttons to filter for archived forms" do
        it "displays 1 archived form" do
          within(".form-filter-buttons") do
            click_on("Archived")
          end
          expect(page).to have_content("ARCHIVED")
          expect(page).to_not have_content("PUBLISHED")
          expect(find_all(".usa-table tbody tr").size).to eq(1)
        end
      end
    end
  end

  context 'as Admin' do
    before do
      login_as(admin)
    end

    describe '/admin/forms' do
      context 'within builder page' do
        let!(:form) { FactoryBot.create(:form, organization:) }

        before do
          visit questions_admin_form_path(form)
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        describe 'can preview a form' do
          before do
            click_on 'Preview'
          end

          it 'can preview a form' do
            within_window(windows.last) do
              expect(page.current_path).to eq(example_admin_form_path(form))
            end
          end
        end
      end

      context 'with multiple (3) forms' do
        let!(:form) { FactoryBot.create(:form, organization:) }
        let!(:form2) { FactoryBot.create(:form, organization:) }
        let!(:form3) { FactoryBot.create(:form, organization:) }
        let!(:form_template) { FactoryBot.create(:form, organization:, template: true, aasm_state: :created) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }
        let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }
        let!(:user_role3) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form3) }

        before do
          visit new_admin_form_path
        end

        context 'Form Templates' do
          it 'is accessible' do
            expect(page).to be_axe_clean
          end

          describe 'can preview a template' do
            before do
              within '.form-templates' do
                click_on 'Preview'
                # Opens in new window
                visit submit_touchpoint_path(form_template)
              end
            end

            it 'can preview a template' do
              within_window(windows.last) do
                expect(page.current_path).to eq(example_admin_form_path(form_template))
                expect(page).to have_content(form_template.modal_button_text)
              end
            end
          end

          describe 'can edit a template' do
            before do
              visit admin_form_path(form_template)
            end

            it 'is accessible' do
              expect(page).to be_axe_clean
            end

            it 'can edit a form template' do
              expect(page.current_path).to eq(admin_form_path(form_template))
              expect(page).to have_content('for Admins'.upcase)
              expect(form_template.template).to eq(true)
              fill_in('form_notes', with: 'Updated notes text')
              click_on 'Update Form Admin Options'
              expect(page.current_path).to eq(admin_form_path(form_template))
            end
          end
        end

        it 'display template forms in a column' do
          within('.form-templates') do
            expect(page).to have_content(form.name)
            expect(page).to have_link('Preview')
            expect(page).to have_link('Copy')
          end
        end

        it "display 'create form' button" do
          expect(page).to have_button('Create Form', disabled: true)
        end

        it "display 'copy form' button" do
          expect(page).to have_button('Copy Form', disabled: true)
        end
      end
    end

    describe '/admin/forms/new' do
      let(:new_form) { FactoryBot.create(:form, :custom, organization:) }

      describe 'new touchpoint hosted form' do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in 'form_name', with: new_form.name
          click_on 'Create Form'
        end

        it 'redirect to /form/:uuid/questions with a success flash message' do
          expect(find('.usa-alert.usa-alert--info')).to have_content('Form was successfully created.')
          @form = Form.last
          expect(page).to have_content('Editing Questions for')
          expect(page).to have_content(@form.name)
          expect(page).to have_content(@form.title)
          expect(page.current_path).to eq(questions_admin_form_path(@form))
        end
      end

      describe 'new inline form' do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in 'form_name', with: new_form.name
          click_on 'Create Form'
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        it 'redirect to /form/:uuid/questions with a success flash message' do
          expect(find('.usa-alert.usa-alert--info')).to have_content('Form was successfully created.')
          @form = Form.last
          expect(page.current_path).to eq(questions_admin_form_path(@form))
        end

        it 'can upload and display a logo' do
          within('.usa-file-input') do
            attach_file('form_logo', 'spec/fixtures/touchpoints-banner.png')
          end
          find('label', text: 'Display square (80px wide by 80px tall) logo?').click
          click_on 'Update logo'
          click_on 'Delivery'
          find('label', text: 'Hosted on touchpoints').click
          click_on 'Update Form'
          expect(page).to have_content('Form was successfully updated.')
          visit example_admin_form_path(Form.last)
          expect(page).to have_css('.form-header-logo-square')
        end
      end

      describe 'new modal form' do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in 'form_name', with: new_form.name
          click_on 'Create Form'
        end

        it 'can upload and display a `square` logo' do
          within('.usa-file-input') do
            attach_file('form_logo', 'spec/fixtures/touchpoints-banner.png')
          end
          find('label', text: 'Display square (80px wide by 80px tall) logo?').click
          click_on 'Update logo'
          click_on 'Delivery'
          find('label', text: 'Embedded inline on your website').click
          fill_in('form_element_selector', with: 'test_selector')
          click_on 'Update Form'
          expect(page).to have_content('Form was successfully updated.')
          visit example_admin_form_path(Form.last)
          within('.fba-modal-dialog') do
            expect(page).to have_css('.form-header-logo-square')
          end
        end

        it 'can upload and display a `banner` logo' do
          within('.usa-file-input') do
            attach_file('form_logo', 'spec/fixtures/touchpoints-banner.png')
          end
          find('label', text: 'Display small banner (320px wide by 80px tall) logo?').click
          click_on 'Update logo'
          click_on 'Delivery'
          find('label', text: 'Embedded inline on your website').click
          fill_in('form_element_selector', with: 'test_selector')
          click_on 'Update Form'
          expect(page).to have_content('Form was successfully updated.')
          visit example_admin_form_path(Form.last)
          within('.fba-modal-dialog') do
            expect(page).to have_css('.form-header-logo')
            # image has 80px height
            image = find('.form-header-logo')
            image_height = image.evaluate_script('this.naturalHeight')
            expect(image_height).to eq(80)
          end
        end
      end

      describe 'Form model validations' do
        let(:existing_form) { FactoryBot.create(:form, :open_ended_form, organization:, omb_approval_number: nil, expiration_date: nil) }

        describe 'missing OMB Approval Number' do
          before 'user tries to update a Touchpoint' do
            visit compliance_admin_form_path(existing_form)
            find('.usa-date-picker__button').click
            expect(page).to have_css('.usa-date-picker--active')
            # arbitrarily pick a date that is next month, third week, third day (from Sunday)
            find('.usa-date-picker__calendar__next-month').click
            within('.usa-date-picker--active table') do
              find_all('tr')[2].find_all('td')[2].click
            end

            click_button 'Update Form'
          end

          it 'display a flash message about missing OMB Approval Number' do
            within('.usa-alert--error') do
              expect(page).to have_content('Omb approval number required with an Expiration Date')
            end
          end
        end

        describe 'missing Expiration Date' do
          before 'user tries to update a Touchpoint' do
            visit compliance_admin_form_path(existing_form)

            fill_in('form[omb_approval_number]', with: 1234)
            click_button 'Update Form'
          end

          it 'display a flash message about missing Expiration Date' do
            within('.usa-alert--error') do
              expect(page).to have_content('Expiration date required with an OMB Number')
            end
          end
        end
      end
    end

    context 'as a Organizational Form Manager' do
      describe '/admin/forms/:uuid' do
        let(:form_manager) { FactoryBot.create(:user, organization:) }
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form:) }

        before do
          login_as(admin)
          visit admin_form_path(form)
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        context 'for :created touchpoint for an Organization form_approval_enabled' do
          describe 'Submit a form' do
            before do
              form.organization.update_attribute(:form_approval_enabled, true)
              form.update(aasm_state: :created)
              visit admin_form_path(form)
              expect(page).to_not have_button("Publish")
              # show this button instead
              click_on 'Submit for Organizational Approval'
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Submitted' flash message" do
              expect(page).to have_content("Viewing Form: #{form.name}")
              expect(page).to have_link("Back to Forms")
              expect(page).to have_content('This form has been Submitted successfully.')
            end
          end
        end
      end
    end

    context 'as a Form Manager' do
      describe '/admin/forms/:uuid' do
        let(:form_manager) { FactoryBot.create(:user, organization:) }
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form:) }

        before do
          login_as(form_manager)
          visit admin_form_path(form)
        end

        context 'for :created touchpoint' do
          describe 'Publish a form' do
            before do
              form.update(aasm_state: :created)
              visit admin_form_path(form)
              click_on 'Publish'
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Published' flash message" do
              expect(page).to have_content('Published')
              expect(page).to have_content("Viewing Form: #{form.name}")
              expect(page).to have_link("Back to Forms")
            end
          end
        end

        context 'for :created touchpoint for an Organization form_approval_enabled' do
          describe 'Submit a form' do
            before do
              form.organization.update_attribute(:form_approval_enabled, true)
              form.update(aasm_state: :created)
              visit admin_form_path(form)
              expect(page).to_not have_button("Publish")
              # show this button instead
              click_on 'Submit for Organizational Approval'
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Submitted' flash message" do
              expect(page).to have_content("Viewing Form: #{form.name}")
              expect(page).to have_link("Back to Forms")
              expect(page).to have_content('This form has been Submitted successfully.')
            end
          end
        end

        context 'for :submitted touchpoint for an Organization form_approval_enabled' do
          describe 'Submit a form' do
            before do
              form.organization.update_attribute(:form_approval_enabled, true)
              form.reset!
              form.submit!
              visit admin_form_path(form)

            end

            it "display when the form was submitted" do
              expect(page).to_not have_button("Publish")
              expect(page).to have_content("Form was submitted for review at")
            end
          end
        end

        context 'for a non-archived touchpoint' do
          describe 'archive' do
            before do
              form.update(aasm_state: :created)
              visit admin_form_path(form)
              click_on 'Archive'
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Archived' flash message" do
              expect(page).to have_content('Archived')
              expect(page).to have_content('Form is not published')
            end
          end
        end

        describe 'reset' do
          before do
            form.update(aasm_state: :published)
            visit admin_form_path(form)
            click_on 'Reset'
            page.driver.browser.switch_to.alert.accept
          end

          it "display 'Reset' flash message" do
            expect(page).to have_content('This form has been reset.')
            expect(page).to have_content('Form is not published')
          end
        end

        context 'copy from form info' do
          it 'can copy a form' do
            click_on 'Copy'
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content('Form was successfully copied')
          end
        end

        describe 'Common Form Elements' do
          context 'title' do
            before do
              visit questions_admin_form_path(form)
            end

            it 'has inline editable title that can be updated and saved' do
              find('.survey-title-input').set('Updated Form Title')
              find('.survey-title-input').native.send_key :tab
              expect(page).to have_content('form title saved')
              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find('.survey-title-input').value).to eq('Updated Form Title')
            end

            it 'has inline editable instructions textbox that can be updated and saved' do
              within '.fba-instructions' do
                fill_in 'form_builder_instructions', with: 'Some <a href="#">HTML Instructions</a> go here'
                find('.instructions').native.send_key :tab
                expect(page).to have_content('go here')
                expect(page).to have_link('HTML Instructions')
                expect(page).to have_content('saved')
              end
              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find('.fba-instructions')).to have_link('HTML Instructions')
              expect(find('.fba-instructions')).to have_content('go here')
            end

            it 'has inline editable disclaimer text textbox that can be updated and saved' do
              fill_in('form_builder_disclaimer', with: 'Disclaaaaaaaimer! with <a href="#">a new link</a>')
              within '.touchpoints-form-disclaimer' do
                find('.disclaimer_text').native.send_key :tab
                expect(page).to have_content('saved')
                expect(find('.disclaimer_text-show')).to have_content('Disclaaaaaaaimer!')
                expect(find('.disclaimer_text-show')).to have_link('a new link')
              end

              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find('.disclaimer_text-show')).to have_content('Disclaaaaaaaimer!')
              expect(find('.disclaimer_text-show')).to have_link('a new link')
            end

            it 'has inline editable success text heading that can be updated and saved' do
              fill_in('form_success_text_heading', with: 'Successful Header!', fill_options: { clear: :backspace })
              find('#form_success_text_heading').native.send_key :tab
              expect(find(".fba-alert.usa-alert.usa-alert--success .usa-alert__heading")).to have_content('Successful Header!')
              wait_for_ajax
              expect(find_field(id: 'form_success_text_heading').value).to have_content('Successful Header!')
              expect(find(".fba-alert.usa-alert.usa-alert--success .usa-alert__heading")).to have_content('Successful Header!')

              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find_field(id: 'form_success_text_heading').value).to have_content('Successful Header!')
            end

            it 'has inline editable success text textbox that can be updated and saved' do
              fill_in('form_success_text', with: 'Sucesssss!')
              within '#success_text_div' do
                find('#form_success_text').native.send_key :tab
                expect(page).to have_content('Sucesssss!')
              end

              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(page).to have_content('Sucesssss!')
            end
          end
        end

        describe 'Submission Export button' do
          context 'when no Submissions exist' do
            before do
              visit responses_admin_form_path(form)
            end

            it 'display text conveying there are no responses yet' do
              expect(page).to have_content('Responses')
              expect(page).to have_content('Export is not available.')
              expect(page).to have_content('This Form has yet to receive any Responses.')
              expect(page).to_not have_link('Export Responses to CSV')
            end
          end

          context 'when Submissions exist' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before do
              visit responses_admin_form_path(form)
            end

            it 'display table list of Responses and Export dropdown' do
              within('table.submissions') do
                expect(page).to have_content(submission.answer_01)
              end
              expect_start_and_end_date_fields
            end
          end
        end

        describe 'reports' do
          context 'for A-11 forms' do
            let!(:a11_form) { FactoryBot.create(:form, :a11, organization:, time_zone: US_TIMEZONES.sample[1]) }
            let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: a11_form) }
            let!(:submission) { FactoryBot.create(:submission, :a11, form: a11_form) }

            before do
              visit responses_admin_form_path(a11_form)
            end

            it 'display table list of Responses and Export responses dropdown' do
              expect(page).to have_content('RESPONSES BY STATUS')
              expect(page).to have_content('Responses per day')
              expect(page).to have_content('Total submissions received over period')
              expect_start_and_end_date_fields
              expect(page).to have_content('Performance.gov Reporting')
              expect(page).to have_content('Responses Summary')
            end

            it 'downloads Response summary successfully' do
              click_on("Responses Summary")
              expect(page).to_not have_content("error")
            end

            it 'downloads Response summary successfully, even without question 7' do
              # Delete Question 7, as many agencies tend to do
              a11_form.questions.select { |q| q.answer_field == "answer_07" }.first.destroy

              click_on("Responses Summary")
              expect(page).to_not have_content("error")
            end
          end
        end

        describe '/admin/forms/:uuid/example' do
          context 'Form with `inline` delivery_method' do
            let!(:inline_form) { FactoryBot.create(:form, :open_ended_form, :inline, organization:) }

            before '/admin/forms/:uuid/example' do
              visit example_admin_form_path(inline_form)
            end

            it 'is accessible' do
              expect(page).to be_axe_clean
            end

            it 'can complete then submit the inline Form and see a Success message' do
              fill_in inline_form.ordered_questions.first.ui_selector, with: 'We the People of the United States, in Order to form a more perfect Union...'
              click_on 'Submit'

              expect(page).to have_content('Success')
              expect(page).to have_content('Thank you. Your feedback has been received.')
            end
          end

          context 'With load_css' do
            let(:form3) { FactoryBot.create(:form, :open_ended_form, :inline, organization:, load_css: true) }

            before '/admin/forms/:uuid/example' do
              visit example_admin_form_path(form3)
            end

            it 'can complete then submit the inline Form and see a Success message' do
              fill_in form3.ordered_questions.first.ui_selector, with: 'We the People of the United States, in Order to form a more perfect Union...'
              click_on 'Submit'

              expect(page).to have_content('Success')
              expect(page).to have_content('Thank you. Your feedback has been received.')
            end
          end
        end
      end

      describe '/admin/forms/:uuid/notifications' do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

        before do
          visit notifications_admin_form_path(form)
          find(".usa-checkbox__label").click
          wait_for_ajax
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        it 'updates successfully' do
          visit notifications_admin_form_path(form)
          expect(find("#checkbox_user_#{admin.id}", visible: false)).to be_checked
        end
      end

      context 'Edit Delivery Method' do
        let!(:form) { FactoryBot.create(:form, :custom, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

        before do
          login_as(admin)
          visit delivery_admin_form_path(form)
        end

        it 'is accessible' do
          expect(page).to be_axe_clean
        end

        describe 'editing the whitelist url' do
          before do
            fill_in 'form_whitelist_url', with: 'https://example.com'
            click_on 'Update Form'
          end

          it 'can edit existing Form' do
            expect(page).to have_content('Form was successfully updated.')
            expect(page.current_path).to eq(delivery_admin_form_path(form))
            expect(find('#form_whitelist_url').value).to eq('https://example.com')
          end
        end

        describe 'editing the whitelist url 3' do
          before do
            fill_in 'form_whitelist_url_3', with: 'https://example.com'
            click_on 'Update Form'
          end

          it 'can edit existing Form' do
            expect(page).to have_content('Form was successfully updated.')
            expect(page.current_path).to eq(delivery_admin_form_path(form))
            expect(find('#form_whitelist_url_3').value).to eq('https://example.com')
          end
        end

        describe 'editing the delivery method' do
          before do
            find('label', text: 'Custom button & modal').click
            click_on 'Update Form'
          end

          it 'fails without specifying the selector' do
            expect(page).to have_content("Element selector can't be blank for an inline form")
          end
        end
      end

      context 'Show Form Page Delete Action' do
        let!(:form) { FactoryBot.create(:form, :single_question, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

        before do
          login_as(admin)
          form.archive!
          visit admin_form_path(form)
        end

        describe 'delete a Form' do
          context 'with no responses' do
            before do
              click_on 'Delete'
              page.driver.browser.switch_to.alert.accept
            end

            it 'can delete existing Form' do
              expect(page).to have_content('Form was successfully destroyed.')
            end
          end

          context 'with responses' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before do
              click_on 'Delete'
              page.driver.browser.switch_to.alert.accept
            end

            it 'cannot delete existing Form' do
              expect(page).to have_content('This form cannot be deleted because it has responses')
            end
          end
        end
      end

      context 'Edit Form page' do
        let!(:form) { FactoryBot.create(:form, :custom, organization:) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

        before do
          login_as(admin)
          visit admin_form_path(form)
        end

        describe 'editing a Form definition' do
          before do
            fill_in 'form_name', with: 'Updated Form Name'
            fill_in 'form_notes', with: 'Updated form notes'
            click_on 'Update Form Options'
            expect(page).to have_content('Form Manager forms options updated successfully')
          end

          it 'can edit existing Form' do
            visit admin_form_path(form)
            expect(page.current_path).to eq(admin_form_path(form))
            expect(find('#form_name').value).to eq('Updated Form Name')
            expect(find('#form_notes').value).to eq('Updated form notes')
          end
        end

        describe 'editing form PRA info' do
          before do
            fill_in 'form_omb_approval_number', with: 'OAN-1234'
            fill_in 'form_expiration_date', with: '2022-01-30'
            click_on 'Update Form Options'
            expect(page).to have_content('Form Manager forms options updated successfully')
          end

          it 'can edit existing Form' do
            visit admin_form_path(form)
            expect(page.current_path).to eq(admin_form_path(form))
            expect(find('#form_omb_approval_number').value).to match('OAN-1234')
            expect(find('#form_expiration_date').value).to eq('2022-01-30')
          end
        end

        describe 'editing form timezone' do
          let!(:form_with_responses) { FactoryBot.create(:form, :single_question, :with_responses, organization:) }
          let!(:additional_response) { FactoryBot.create(:submission, form: form_with_responses, answer_01: "hi", created_at: "2025-01-02") }
          let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form_with_responses) }

          before do
            select(US_TIMEZONES.sample[1], from: 'form_time_zone')
            click_on 'Update Form Options'
            expect(page).to have_content('Form Manager forms options updated successfully')
          end

          it 'renders valid time' do
            visit responses_admin_form_path(form_with_responses)
            expect(page.all("#submissions_table .usa-table.submissions tbody tr").size).to eq(4)
          end

          it 'ensure format_time translation is correct' do
            visit responses_admin_form_path(form_with_responses)
            expect(all("#submissions_table .usa-table.submissions tbody tr").last).to have_content("Jan 1")
          end
        end

        describe 'modifying Form Sections' do
          it 'cannot delete the only remaining form section' do
            expect(page).to_not have_content('Delete Form Section')
          end
        end

        context 'Form Sections' do
          before do
            login_as(admin)
          end

          describe 'adding Form Sections' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Section'
              find_all('.section-title').last.native.send_keys :tab
            end

            it 'displays /admin/forms/:id/form_sections/new' do
              expect(find_all('.section-title').last.value).to eq('New Section')
            end
          end

          describe 'editing Form Sections' do
            before do
              visit questions_admin_form_path(form)
            end

            describe 'FormSection.title' do
              it 'displays editable input that can be updated and saved' do
                expect(find('.section-title').value).to eq('Page 1')
                find('.section-title').fill_in with: 'New Form Section Title'
                find('.section-title').native.send_keys :tab

                expect(find('.section-title').value).to eq('New Form Section Title')
                # and persists after refresh
                visit questions_admin_form_path(form)
                expect(find('.section-title').value).to eq('New Form Section Title')
              end
            end
          end

          describe 'delete Form Sections' do
            before do
              visit questions_admin_form_path(form)
            end

            it 'is accessible' do
              expect(page).to be_axe_clean
            end

            it 'defaults to 1 section' do
              expect(find_all('.section').size).to eq(1)
            end

            describe 'with at least 2 Sections' do
              let!(:form_section2) { FactoryBot.create(:form_section, form:, position: 2) }

              before do
                visit questions_admin_form_path(form)
              end

              it 'display successful flash message' do
                expect(find_all('.section').size).to eq(2)
                find_all('.section').last.click_on 'Delete Section'
                page.driver.browser.switch_to.alert.accept
                expect(page.current_path).to eq(questions_admin_form_path(form))
                expect(page).to have_content('Form section was successfully deleted.')
                expect(find_all('.section').size).to eq(1)
              end
            end
          end
        end

        describe 'character limit field' do
          before do
            visit questions_admin_form_path(form)
            find(".form-add-question").click
          end

          it 'shows character limit field' do
            choose 'question_question_type_text_field'
            expect(page).to have_content('Character limit')
            choose 'question_question_type_textarea'
            expect(page).to have_content('Character limit')
          end

          it 'hides character limit field' do
            choose 'question_question_type_radio_buttons'
            expect(page).not_to have_content('Character limit')
            choose 'question_question_type_dropdown'
            expect(page).not_to have_content('Character limit')
            choose 'question_question_type_checkbox'
            expect(page).not_to have_content('Character limit')
          end
        end

        describe 'adding Questions' do
          describe 'help text and placeholder text' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              fill_in 'question_text', with: 'New Test Question'
              choose 'question_question_type_text_field'
              fill_in 'question_help_text', with: 'Additional help text for this question'
              fill_in 'question_placeholder_text', with: 'Placeholder text for this question'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'persist and display help text' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Test Question')
                expect(page).to have_content('Additional help text for this question')
                expect(page).to have_css("input##{form.ordered_questions.last.ui_selector}[type='text']")
              end
            end

            it 'persist and display placeholder text' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Test Question')
                expect(page).to have_css("input##{form.ordered_questions.last.ui_selector}[type='text']")
                expect(find("##{form.ordered_questions.last.ui_selector}")['placeholder']).to eq('Placeholder text for this question')
              end
            end
          end

          describe 'add a Text Field question' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              fill_in 'question_text', with: 'New Test Question'
              choose 'question_question_type_text_field'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'can add a Text Field Question' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Test Question')
                expect(page).to have_css("input[type='text']")
              end
            end
          end

          describe 'add a Text Phone Field question' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              fill_in 'question_text', with: 'New Test Question'
              choose 'question_question_type_text_phone_field'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'can add a Text Field Question' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Test Question')
                expect(page).to have_css("input[type='tel']")
              end
            end
          end

          describe 'add a Text Area question' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              fill_in 'question_text', with: 'New Text Area'
              choose 'question_question_type_textarea'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'can add a Text Area question' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Text Area')
                expect(page).to have_css('textarea')
              end
            end
          end

          describe 'add a Radio Buttons question' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              fill_in 'question_text', with: 'New Test Question Radio Buttons'
              choose 'question_question_type_radio_buttons'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'can add a Text Field Question' do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder .question' do
                expect(page).to have_content('New Test Question Radio Buttons')
                # Radio buttons won't be showing yet. Because they need to be added.
              end
            end
          end

          describe 'add a Checkbox question' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              choose 'question_question_type_checkbox'
              select('answer_01', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'can add a Checkbox Question' do
              expect(page).to have_link('Add Checkbox Option')
            end

            it 'can cancel a Checkbox Question' do
              click_on 'Add Checkbox Option'
              expect(page).to have_content('New Question Option')
              click_on 'Cancel'
              expect(page.current_path).to eq(admin_form_questions_path(form))
              expect(page).not_to have_content('New Question Option')
            end

            describe 'adding multiple question options' do
              before do
                click_on 'Add Checkbox Option'
                fill_in "question_option_text", with: "a\nb\nc"
                click_on "Create Question option"
              end

              it 'renders 3 question options' do
                within(".question-options") do
                  expect(find_all(".question-option").size).to eq(3)
                end
              end
            end
          end

          describe '#edit question and cancel' do
            let!(:first_question) { FactoryBot.create(:question, form:, form_section: form.form_sections.first, answer_field: :answer_01) }

            before do
              visit questions_admin_form_path(form)
              expect(page.current_path).to eq(questions_admin_form_path(form))
              expect(page).to have_content('Test Question')
              find(".form-edit-question").click
              expect(page).to have_button('Update Question')
              expect(page).to have_link('Cancel')
              expect(page).to have_link('Delete Question')
            end

            it 'removes the edit form on cancel' do
              click_on 'Cancel'
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder' do
                expect(page).not_to have_content('Cancel')
              end
            end

            it 'does not persist change on cancel' do
              fill_in 'question_text', with: 'Canceled question'
              click_on 'Cancel'
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within '.form-builder' do
                expect(page).not_to have_content('Canceled question')
              end
            end
          end

          describe 'chaining add edit question operations' do
            before do
              visit questions_admin_form_path(form)
            end

            it 'successfully executes add-update-add-update sequence' do
              click_on 'Add Question'
              click_on 'Update Question'
              expect(page).not_to have_content('prohibited this question from being saved')
              click_on 'Add Question'
              click_on 'Update Question'
              expect(page).not_to have_content('prohibited this question from being saved')
            end
          end

          describe 'answer display' do
            let!(:first_question) { FactoryBot.create(:question, form:, form_section: form.form_sections.first, answer_field: :answer_01) }

            before do
              visit questions_admin_form_path(form)
              find(".form-add-question").click
            end

            it 'displays answers that are not assigned to other Questions' do
              expect(find('#question_answer_field')).to_not have_content('answer_01')
              expect(find('#question_answer_field')).to have_content('answer_02')
            end
          end

          context 'Dropdown Question' do
            describe '#create' do
              before do
                visit questions_admin_form_path(form)
                click_on 'Add Question'
                expect(page.current_path).to eq(questions_admin_form_path(form))
                choose 'question_question_type_dropdown'
                fill_in 'question_text', with: 'New dropdown field'
                select('answer_01', from: 'question_answer_field')
                click_on 'Update Question'
                expect(page).to have_css("##{form.ordered_questions.first.ui_selector}")
              end

              it 'can add a dropdown Question' do
                expect(page.current_path).to eq(questions_admin_form_path(form))
                within '.form-builder' do
                  expect(page).to have_content('New dropdown field')
                  # Radio buttons won't be showing yet. Because they need to be added.
                end
              end

              describe '#edit' do
                before do
                  visit questions_admin_form_path(form)
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  expect(page).to have_content('New dropdown field')
                  find(".form-edit-question").click
                  expect(find_field('question_text').value).to eq 'New dropdown field'
                end

                it 'add a Question Option for a dropdown' do
                  fill_in 'question_text', with: 'Updated question text'
                  click_on 'Update Question'

                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  within '.form-builder' do
                    expect(page).to have_content('Updated question text')
                  end
                end
              end

              describe 'Question Options for a dropdown' do
                before do
                  visit questions_admin_form_path(form)
                  click_on 'Add Dropdown Option'
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  fill_in 'question_option_text', with: 'Dropdown option #1'
                  # Create the option
                  click_on 'Create Question option'
                end

                it 'add a Question Option for a dropdown' do
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  expect(page).to have_content('Dropdown option #1')

                  within ".form-builder .question-options .question-option[data-id='#{QuestionOption.last.id}']" do
                    expect(page).to have_content('Dropdown option #1')
                    expect(page).to have_css('.delete.button')
                  end

                  # Update the option
                  within('.question-options') do
                    find_all('.question-option .question-option-view').first.click
                    wait_for_ajax
                    fill_in 'question_option_text', with: 'Edited Question Option Text'
                    fill_in 'question_option_value', with: '100'
                    find('.fa-save').click
                  end
                  expect(page).to have_content('Edited Question Option Text (100)')
                end

                it 'will prevent updating a question option with no text' do
                  click_on 'Create Question option'
                  page.driver.browser.switch_to.alert.accept
                  expect(page).to have_button('Create Question option')
                end

                it 'can cancel a Dropdown Question option' do
                  click_on 'Cancel'
                  wait_for_ajax
                  expect(page.current_path).to eq(admin_form_questions_path(form))
                  expect(page).not_to have_content('New Question Option')
                end
              end
            end
          end

          context 'States Dropdown Question' do
            describe '#create' do
              before do
                visit questions_admin_form_path(form)
                click_on 'Add Question'
                expect(page.current_path).to eq(questions_admin_form_path(form))
                choose 'question_question_type_states_dropdown'
                fill_in 'question_text', with: 'New dropdown field'
                select('answer_01', from: 'question_answer_field')
                click_on 'Update Question'
                expect(page).to have_css("##{form.ordered_questions.last.ui_selector}")
              end

              it 'can add a dropdown Question' do
                expect(page.current_path).to eq(questions_admin_form_path(form))
                within '.form-builder' do
                  expect(page).to have_content('New dropdown field')
                end
              end

              describe '#edit' do
                before do
                  visit questions_admin_form_path(form)
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  find(".form-edit-question").click
                  expect(find_field('question_text').value).to eq 'New dropdown field'
                end

                it 'add a Question Option for a dropdown' do
                  fill_in 'question_text', with: 'Updated question text'
                  click_on 'Update Question'

                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  within '.form-builder' do
                    expect(page).to have_content('Updated question text')
                  end
                end
              end
            end
          end

          describe 'add a text display element' do
            before do
              visit questions_admin_form_path(form)
              click_on 'Add Question'
              expect(page.current_path).to eq(questions_admin_form_path(form))
              choose 'question_question_type_text_display'
              fill_in 'question_text', with: 'Some custom <a href="#">html</a>'
              select('answer_20', from: 'question_answer_field')
              click_on 'Update Question'
            end

            it 'display text display element with html' do
              within '.form-builder .question' do
                expect(page).to have_content('Some custom')
                expect(page).to have_link('html')
              end
            end
          end
        end

        describe 'deleting Questions' do
          let(:form2) { FactoryBot.create(:form, :custom, organization:) }
          let(:form_section2) { FactoryBot.create(:form_section, form: form2, position: 2) }
          let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }
          let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }

          context 'with Form Manager permissions' do
            before do
              visit questions_admin_form_path(form2)
              find(".form-edit-question").click
            end

            it 'display the Delete Question button' do
              expect(page).to have_link('Delete')
            end
          end
        end

        describe 'adding Question Options' do
          describe 'add Radio Button options' do
            let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form:, form_section: form.form_sections.first) }

            before do
              visit questions_admin_form_path(form)
              click_on 'Add Radio Button Option'
              expect(page).to have_content('New Question Option')
              expect(page).to have_selector('.well #question_option_text:focus')
              expect(page).to have_content("for the question: #{radio_button_question.text}")
              expect(page).to have_content('with a question_type of: radio_buttons')
            end

            it 'Question Option value is populated with Question Option name by default, on outfocus' do
              fill_in('question_option_text', with: 'New Test Radio Option')
              page.evaluate_script("$('#question_option_value').focus()")
              expect(find('#question_option_value').value).to eq('New Test Radio Option')
            end

            it 'create a Radio Button option' do
              fill_in('question_option_text', with: 'New Test Radio Option')
              fill_in('question_option_value', with: '123')
              click_on('Create Question option')

              expect(page).to have_content('New Test Radio Option')
              within ".form-builder .question-options .question-option[data-id='#{QuestionOption.last.id}']" do
                expect(all('label').last).to have_content('New Test Radio Option')
              end
            end

            it 'can cancel a Radio Button question' do
              expect(page).to have_content('New Question Option')
              click_on 'Cancel'
              expect(page.current_path).to eq(admin_form_questions_path(form))
              expect(page).not_to have_content('New Question Option')
            end
          end

          describe 'add "Other" Radio Button option' do
            let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form:, form_section: form.form_sections.first) }

            before do
              visit questions_admin_form_path(form)
              click_on 'Add Other Option'
            end

            it "create other question option and a text field" do
              expect(page).to have_content('Other (OTHER)')
              expect(page).to have_content('Enter other text')
              expect(page).to have_css('input.other-option')
            end
          end

          describe 'adding Checkbox options' do
          end

          describe 'add "Other" Checkbox Button option' do
            let!(:checkbox_question) { FactoryBot.create(:question, :with_checkbox_options, form:, form_section: form.form_sections.first) }

            before do
              visit questions_admin_form_path(form)
              click_on 'Add Other Option'
            end

            it "create other question option and a text field" do
              expect(page).to have_content('Other (OTHER)')
              expect(page).to have_content('Enter other text')
              expect(page).to have_css('input.other-option')
            end
          end

          xdescribe 'adding Dropdown options' do
          end
        end

        describe 'editing Question Options' do
          let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: admin) }

          describe 'edit Radio Button option' do
            let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form:, form_section: form.form_sections.first) }
            let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

            before do
              visit questions_admin_form_path(form)
              within('.question-options') do
                find_all('.question-option .question-option-view').first.click
                fill_in 'question_option_text', with: 'Edited Question Option Text'
                fill_in 'question_option_value', with: '100'
                find('.fa-save').click
              end
            end

            it 'display the updated text and custom value' do
              expect(page).to have_content('Edited Question Option Text (100)')
            end
          end

          describe 'edit Dropdown option' do
            let!(:dropdown_question) { FactoryBot.create(:question, :with_dropdown_options, form:, form_section: form.form_sections.first) }
            let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: admin) }

            before do
              visit questions_admin_form_path(form)
              find_all('.question-option-view').first.click
              fill_in 'question_option_text', with: 'Edited Question Option Text'
              fill_in 'question_option_value', with: '100'
              find('.button.form-save-question-option').click
            end

            it 'display updated text and value' do
              expect(page).to have_content('Edited Question Option Text (100)')
              expect(find_all('.question-option-view').first).to have_content('Edited Question Option Text (100)')
            end
          end
        end
      end
    end
  end

  context 'Form owner with Form Manager permissions Delete Action' do
    let!(:form) { FactoryBot.create(:form, :single_question, organization:) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

    let(:user) { FactoryBot.create(:user, organization:) }

    let(:another_organization) { FactoryBot.create(:organization, :another) }
    let(:another_user) { FactoryBot.create(:user, email: 'user@another.gov', organization: another_organization) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: another_user) }

    before do
      login_as(another_user)
      form.archive!
      visit admin_form_path(form)
    end

    describe 'can delete a Form' do
      context 'with no responses' do
        before do
          click_on 'Delete'
          page.driver.browser.switch_to.alert.accept
        end

        it 'can delete existing Form' do
          expect(page).to have_content('Form was successfully destroyed.')
        end
      end

      context 'with responses' do
        let!(:submission) { FactoryBot.create(:submission, form:) }

        before do
          click_on 'Delete'
          page.driver.browser.switch_to.alert.accept
        end

        it 'cannot delete existing Form' do
          expect(page).to have_content('This form cannot be deleted because it has responses')
        end
      end
    end
  end

  context 'Form Manager with an A11 v2 form' do
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, :a11_v2, organization:) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: user) }

    describe "a valid a11 form" do
      before do
        login_as(user)
        visit questions_admin_form_path(form)
      end

      it 'displays no validation warnings' do
        expect(page.current_path).to eq(questions_admin_form_path(form))
        expect(page).to_not have_content('This form needs attention:')
        expect(page).to have_content("Please rate your experience as a customer of Agency of Departments.")
      end
    end

    describe "an invalid a11 form" do
      before do
        q1 = form.ordered_questions.first
        q1.update(question_type: "radio_buttons") # update this question to an invalid question_type (for the a11-v2)
        q2 = form.ordered_questions.second
        q2.question_options.delete_all
        q3 = form.ordered_questions.third
        q3.question_options.delete_all
        q4 = form.ordered_questions.last.destroy # remove question 4
        login_as(user)
        visit questions_admin_form_path(form)
      end

      it 'displays a11 v2 form validation warnings' do
        expect(page).to have_content('This form needs attention:')
        expect(page).to have_content('The question for `answer_01` must be a "Big Thumbs Up/Down" component')
        expect(page).to have_content('The A-11 v2 form must have questions for answer_01, answer_02, answer_03, and answer_04')
        expect(page).to have_content('The question options for Question 2 must include: effectiveness, ease')
        expect(page).to have_content('The question options for Question 3 must include: effectiveness, ease')
      end
    end
  end

  context 'Form owner with Form Manager permissions' do
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:form) { FactoryBot.create(:form, :custom, organization:) }

    let(:another_organization) { FactoryBot.create(:organization, :another) }
    let(:another_user) { FactoryBot.create(:user, email: 'user@another.gov', organization: another_organization) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: another_user) }

    before do
      login_as(another_user)
      visit edit_admin_form_path(form)
    end

    it 'can edit form' do
      expect(page.current_path).to eq(edit_admin_form_path(form))
      expect(page).to have_content('Editing Form')
    end

    it "regression: edit does not set the Organization to the user's org" do
      click_on 'Update Form'
      expect(page).to have_content('Organization')
      expect(page).to have_content('Example.gov')
    end
  end

  context 'user without Form Manager permissions' do
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:user2) { FactoryBot.create(:user, organization:) }
    let!(:form) { FactoryBot.create(:form, :custom, organization:) }

    describe 'cannot edit the form' do
      context '/admin/forms/:id/edit' do
        before do
          login_as(user)
          visit edit_admin_form_path(form)
        end

        it 'redirects to /admin' do
          expect(page.current_path).to eq(admin_root_path)
          expect(page).to have_content('Authorization is Required')
        end
      end
    end
  end

  context 'without Form Manager permissions' do
    let(:user) { FactoryBot.create(:user, organization:) }
    let(:another_user) { FactoryBot.create(:user, organization:) }
    let!(:another_users_form) { FactoryBot.create(:form, :custom, organization:) }

    describe 'reduced UI features on /edit' do
      before do
        login_as(user)
        visit edit_admin_form_path(another_users_form)
      end

      it 'does not see the Delete Question button' do
        expect(page).to_not have_link('Delete')
      end
    end

    describe 'insufficient privileges to /permissions' do
      before do
        login_as(user)
        visit permissions_admin_form_path(another_users_form)
      end

      it 'is accessible' do
        expect(page).to be_axe_clean
      end

      it 'is redirected away and shown a message' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq admin_root_path
      end
    end

    describe 'insufficient privileges to /questions' do
      before do
        login_as(user)
        visit questions_admin_form_path(another_users_form)
      end

      it 'is redirected away and shown a message' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq admin_root_path
      end
    end
  end

  context 'as Touchpoints Manager' do
    let(:touchpoints_manager) { FactoryBot.create(:user, organization:) }

    before do
      login_as(touchpoints_manager)
    end

    context '#new form page' do
      before do
        visit new_admin_form_path
      end

      describe 'create a form feature' do
        it 'Create button is disabled by default' do
          expect(find("input[value='Create Form']").disabled?).to be(true)
        end
      end

      describe 'copy a form feature' do
        it 'Copy button is disabled by default' do
          expect(find("input[value='Copy Form']").disabled?).to be(true)
        end
      end
    end

    describe 'create a form' do
      before do
        visit new_admin_form_path
        fill_in 'form_name', with: 'New test form name'
        click_on 'Create Form'
      end

      it 'arrives at /admin/forms/:uuid/questions' do
        within('.usa-alert--info .usa-alert__body') do
          expect(page).to have_content('Form was successfully created')
        end
        expect(page).to have_content('Editing Questions for:')
        expect(page).to have_content('Form is not published')
        expect(page).to have_button('Publish')
        expect(page).to have_link('Copy')
        expect(page).to have_link('Archive')
        expect(page).to have_link('Delete')
      end
    end

    describe 'copying a Form' do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: touchpoints_manager) }

      before do
        visit admin_forms_path
        within('.float-menu') do
          find('button').click
          find("#extended-nav-section-one-#{form.short_uuid}", visible: true)
        end
        click_link('Copy')
        page.driver.browser.switch_to.alert.accept
      end

      it 'conveys the form was successfully copied' do
        expect(page).to have_content('Form was successfully copied.')
        expect(page.current_path).to eq(admin_form_path(Form.last.short_uuid))
        expect(page).to have_content('Viewing Form')
        expect(page).to have_content("Copy of #{form.name}")
        expect(page).to have_content('0 responses')
      end
    end

    describe 'adding tags to a form' do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form:, user: touchpoints_manager) }

      context "with no tags" do
        before do
          visit admin_form_path(form)
          fill_in "form_tag_list", with: "health benefits"
          page.find('#form_tag_list').native.send_keys :tab # to lose focus
          expect(page).to have_content("health benefits".upcase)
          fill_in "form_tag_list", with: "digital service"
          page.find('#form_tag_list').native.send_keys :tab
        end

        it 'adds tags' do
          within(".tag-list") do
            expect(page).to have_content("health benefits".upcase)
            expect(page).to have_content("digital service".upcase)
          end
        end
      end

      context "with tags" do
        before do
          form.update_attribute(:tag_list, "aaa, zzz")
          visit admin_form_path(form)
        end

        it 'removes tags' do
          find_all(".remove-tag-link").first.click
          within(".tag-list") do
            expect(page).to_not have_content("aaa".upcase)
            expect(page).to have_content("zzz".upcase)
          end
          visit admin_form_path(form)
          within(".tag-list") do
            expect(page).to_not have_content("aaa".upcase)
            expect(page).to have_content("zzz".upcase)
          end
        end
      end

    end

    describe 'deleting Questions' do
      let!(:form2) { FactoryBot.create(:form, :custom, organization:) }
      let!(:form_section2) { FactoryBot.create(:form_section, form: form2, position: 2) }
      let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }

      context 'with Form Manager permissions' do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, { form: form2, user: touchpoints_manager }) }

        before do
          visit questions_admin_form_path(form2)
          find(".form-edit-question").click
        end

        it 'see the delete button, click it, and delete the question' do
          expect(page).to have_css(".question#question_#{form2.id}")
          expect(page).to have_link('Delete Question')
          click_on('Delete Question')
          page.driver.browser.switch_to.alert.accept
          expect(page).to_not have_css(".question#question_#{form2.id}")
        end

        describe 'multiple Touchpoint Form Sections' do
          let(:new_title) { 'New Form Section Title' }

          before do
            visit questions_admin_form_path(form2)
            expect(page).to have_selector('.form-add-question', count: 2)
            find("#form_section_1").find('.form-add-question').click
            fill_in 'question_text', with: 'Question in Form Section 1'
            select('text_field', from: 'question_question_type')
            click_on 'Update Question'
            expect(page).to have_css(".usa-tag", text: "ANSWER_02")
            # Select the Add Question button in the 2nd Form Section
            visit questions_admin_form_path(form2)
            expect(find_all('.form-add-question').size).to eq(2)
            find("#form_section_2").find('.form-add-question').click
            fill_in 'question_text', with: 'Question in Form Section 2'
            select('text_field', from: 'question_question_type')
            click_on 'Update Question'
            # Wait for Add Question to re-appear
            expect(page).to have_selector('#form_section_1 .form-add-question', count: 1)
            expect(page).to have_selector('#form_section_2 .form-add-question', count: 1)
          end

          it 'creates the question in the correct Form Section' do
            within('#form_section_1') do
              expect(page).to have_content('Question in Form Section 1')
            end
            within('#form_section_2') do
              expect(page).to have_content("ANSWER_03")
              expect(page).to have_content('Question in Form Section 2')
            end
          end
        end
      end
    end

    describe '/forms/:id.json' do
      let(:form_manager) { FactoryBot.create(:user, organization:) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
      let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form:, form_section: form.form_sections.first, answer_field: :answer_02) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form:) }

      before do
        visit admin_form_path(form, format: :json)
      end

      it 'includes form attributes' do
        expect(page).to have_content('form')
        expect(page).to have_content('questions')
        expect(page).to have_content('question_options')
      end
    end

    describe '#export' do
      let(:form_manager) { FactoryBot.create(:user, organization:) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, :with_100_responses, organization:) }
      let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form:, form_section: form.form_sections.first, answer_field: :answer_02) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form:) }

      before do
        login_as(form_manager)
        visit responses_admin_form_path(form)
        click_on "Download"
      end

      it 'remains on page' do
        expect(page.current_path).to eq(responses_admin_form_path(form))
      end
    end
  end

  context 'as Response Viewer' do
    describe '/admin/forms/:uuid' do
      let(:response_viewer) { FactoryBot.create(:user, organization:) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
      let!(:user_role) { FactoryBot.create(:user_role, :response_viewer, user: response_viewer, form:) }

      before do
        login_as(response_viewer)
        visit admin_form_path(form)
      end

      describe 'unavailable UI features' do
        it "does not display 'Publish' component" do
          expect(page).not_to have_content('Publish your form')
        end

        it 'does not Form Manager options' do
          expect(page).not_to have_content('form Form Managers'.upcase)
          expect(page).not_to have_content('Update Form')
        end

        it "does not display 'Roles and Permissions' component" do
          expect(page).not_to have_content('Roles & Permissions')
        end
      end

      describe 'Submission Export button' do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

        context 'when no Submissions exist' do
        end

        context 'when Submissions exist' do
          let!(:submission) { FactoryBot.create(:submission, form:) }

          before do
            visit responses_admin_form_path(form)
          end

          it 'display table list of Responses and Export CSV dropdown' do
            within('table.submissions') do
              expect(page).to have_content(submission.answer_01)
            end
            expect_start_and_end_date_fields
          end
        end
      end

      context 'when Submissions exist for an a11_v2 form' do
        describe 'click the combined download button' do
          let(:form) { FactoryBot.create(:form, :a11_v2, organization:) }
          let!(:submission) { FactoryBot.create(:submission, form:, answer_01: "1") }

          before do
            visit responses_admin_form_path(form)
          end

          it 'click the combine download button then see a flash message for an async job' do
            expect(page).to have_content("to see form and A-11 responses together")
            click_on("Download A11-v2 + Form Responses")
            expect(page).to have_content("Touchpoints has initiated an asynchronous job that will take a few minutes.")
          end
        end
      end
    end

    context 'user for another Form' do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

      before do
        login_as(user)
      end

      describe 'insufficient privileges to /permissions' do
        before do
          visit permissions_admin_form_path(form)
        end

        it 'is redirected away and shown a message' do
          expect(page).to have_content('Authorization is Required')
          expect(page.current_path).to eq admin_root_path
        end
      end

      describe 'insufficient privileges to /questions' do
        before do
          visit questions_admin_form_path(form)
        end

        it 'is redirected away and shown a message' do
          expect(page).to have_content('Authorization is Required')
          expect(page.current_path).to eq admin_root_path
        end
      end
    end

    describe '/admin/forms/:uuid/example' do
      describe 'Form with `inline` delivery_method' do
        let(:form2) { FactoryBot.create(:form, :open_ended_form, :inline, organization:) }

        before '/admin/forms/:uuid/example' do
          login_as(admin)
          visit example_admin_form_path(form2)
        end

        it 'can complete then submit the inline Form and see a Success message' do
          fill_in form2.ordered_questions.first.ui_selector, with: 'We the People of the United States, in Order to form a more perfect Union...'
          click_on 'Submit'
          expect(page).to have_content('Success')
          expect(page).to have_content('Thank you. Your feedback has been received.')
        end
      end
    end
  end

  context 'as non-logged in User' do
    let!(:form_template) { FactoryBot.create(:form, organization:, template: true, aasm_state: :created) }

    describe 'cannot access forms' do
      before do
        visit admin_forms_path
      end

      it 'display flash message on homepage' do
        expect(page.current_path).to eq(index_path)
        expect(page).to have_content('Authorization is Required')
      end
    end

    describe 'cannot preview a form template' do
      before do
        visit submit_touchpoint_path(form_template)
      end

      it 'cannot preview a form template' do
        expect(page.current_path).to eq(index_path)
        expect(page).to have_content('Form is not currently deployed.')
      end
    end
  end

  describe '/invite' do
    let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

    before do
      login_as(admin)
    end

    context 'with a valid email' do
      before do
        visit admin_invite_path(form)
      end

      it 'sends an invite to the designated user' do
        fill_in('user[refer_user]', with: 'newuser@domain.gov')
        click_on 'Invite User'
        expect(page).to have_content('Invite sent to newuser@domain.gov')
        expect(page.current_path).to eq(admin_invite_path)
      end
    end

    context 'with an invalid email' do
      before do
        visit admin_invite_path
      end

      it 'initially disabled button shows an alert when at least 6 characters of an invalid email address is provided' do
        expect(find("#invite-button").disabled?).to be(true)
        fill_in('user[refer_user]', with: 'some')
        expect(find("#invite-button").disabled?).to be(true)

        # add more than 6 characters, to activate the submit button
        find('#user_refer_user').send_keys('some@address.com')
        expect(find("#invite-button").disabled?).to be(false)
        click_on 'Invite User'
        expect(page).to have_content('Please enter a valid .gov or .mil email address')
        expect(page.current_path).to eq(admin_invite_path)
      end

      it 'shows a gov-specific user alert when the email address is not a valid email' do
        fill_in('user[refer_user]', with: 'test@example.com')
        click_on 'Invite User'
        expect(page).to have_content('Please enter a valid .gov or .mil email address')
        expect(page.current_path).to eq(admin_invite_path)
      end

      context 'when using GitHub for oAuth' do
        before do
          ENV['GITHUB_CLIENT_ID'] = 'something'
        end

        it 'shows an HTML validation user alert when the email address is not valid' do
          expect(page).to have_content('Invite a colleague')
          fill_in('user[refer_user]', with: 'testing')
          click_on 'Invite User'
          message = page.find('#user_refer_user').native.attribute('validationMessage')
          expect(message).to have_content "Please include an '@' in the email address."
        end

        after do
          ENV['GITHUB_CLIENT_ID'] = nil
        end
      end

      it 'shows an alert when the email address already exists' do
        fill_in('user[refer_user]', with: user.email)
        click_on 'Invite User'
        expect(page).to have_content("User with email #{user.email} already exists")
        expect(page.current_path).to eq(admin_invite_path)
      end
    end
  end
end
