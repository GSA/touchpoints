require 'rails_helper'

feature "Forms", js: true do
  let(:future_date) {
    Time.now + 3.days
  }
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  context "as Admin" do
    before do
      login_as(admin)
    end

    describe "/admin/forms" do
      context "with multiple (3) forms" do
        let!(:form) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form2) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form3) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form_template) { FactoryBot.create(:form, organization: organization, user: user, template: true, aasm_state: :in_development)}
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }
        let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }
        let!(:user_role3) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form3) }

        before do
          visit new_admin_form_path
        end

        context "Form Templates" do
          describe "can preview a template" do
            before do
              within ".form-templates" do
                click_on "Preview"
                # Opens in new window
                visit submit_touchpoint_path(form_template)
              end
            end

            it "can preview a template" do
              within_window(windows.last) do
                expect(page.current_path).to eq(example_admin_form_path(form_template))
                expect(page).to have_content(form_template.modal_button_text)
              end
            end
          end

          describe "can edit a template" do
            before do
              visit edit_admin_form_path(form_template)
            end

            it "can edit a form template" do
              expect(page.current_path).to eq(edit_admin_form_path(form_template))
              expect(page).to have_content("Editing Survey")
              expect(form_template.template).to eq(true)
              fill_in("form_notes", with: "Updated notes text")
              click_on "Update Survey"
              expect(page).to have_content("Survey was successfully updated.")
              expect(page.current_path).to eq(admin_form_path(form_template))
              expect(page).to have_content("Updated notes text")
            end
          end
        end

        it "display template forms in a column" do
          within(".form-templates") do
            expect(page).to have_content(form.name)
            expect(page).to have_link("Preview")
            expect(page).to have_link("Use")
          end
        end

        it "display 'create survey' button" do
          expect(page).to have_button("Create Survey", disabled: true)
        end

        it "display 'copy survey' button" do
          expect(page).to have_button("Copy Survey", disabled: true)
        end
      end
    end

    describe "/admin/forms/new" do
      let(:new_form) { FactoryBot.create(:form, :custom, organization: organization, user: admin) }

      describe "new touchpoint hosted form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in "form_name", with: new_form.name
          click_on "Create Survey"
        end

        it "redirect to /form/:uuid/questions with a success flash message" do
          expect(find('.usa-alert.usa-alert--info')).to have_content("Survey was successfully created.")
          @form = Form.last
          expect(page).to have_content("Editing Questions for")
          expect(page).to have_content(@form.name)
          expect(page).to have_content(@form.title)
          expect(page.current_path).to eq(questions_admin_form_path(@form))
        end
      end

      describe "new inline form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in "form_name", with: new_form.name
          click_on "Create Survey"
        end

        it "redirect to /form/:uuid/questions with a success flash message" do
          expect(find('.usa-alert.usa-alert--info')).to have_content("Survey was successfully created.")
          @form = Form.last
          expect(page.current_path).to eq(questions_admin_form_path(@form))
        end
      end

      describe "Form model validations" do
        let(:existing_form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, omb_approval_number: nil, expiration_date: nil)}

        describe "missing OMB Approval Number" do
          before "user tries to update a Touchpoint" do
            visit compliance_admin_form_path(existing_form)
            find(".usa-date-picker__button").click
            expect(page).to have_css(".usa-date-picker--active")
            # arbitrarily pick a date that is next month, third week, third day (from Sunday)
            find(".usa-date-picker__calendar__next-month").click
            within(".usa-date-picker--active table") do
              find_all("tr")[2].find_all("td")[2].click
            end

            click_button "Update Survey"
          end

          it "display a flash message about missing OMB Approval Number" do
            within(".usa-alert--error") do
              expect(page).to have_content("Omb approval number required with an Expiration Date")
            end
          end
        end

        describe "missing Expiration Date" do
          before "user tries to update a Touchpoint" do
            visit compliance_admin_form_path(existing_form)

            fill_in("form[omb_approval_number]", with: 1234)
            click_button "Update Survey"
          end

          it "display a flash message about missing Expiration Date" do
            within(".usa-alert--error") do
              expect(page).to have_content("Expiration date required with an OMB Number")
            end
          end
        end
      end
    end

    context "as a Form Manager" do
      describe "/admin/forms/:uuid" do
        let(:form_manager) { FactoryBot.create(:user, organization: organization) }
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user)}
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: form) }

        before do
          login_as(form_manager)
          visit admin_form_path(form)
        end

        context "for :in_development touchpoint" do
          describe "Publishing" do
            before do
              form.update(aasm_state: :in_development)
              visit admin_form_path(form)
              click_on "Publish"
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Published' flash message" do
              expect(page).to have_content("Published")
              expect(page).to have_content("Viewing Survey: #{form.name}")
              expect(page).to have_content("Form Information")
            end
          end
        end

        context "for a non-archived touchpoint" do
          describe "archive" do
            before do
              form.update(aasm_state: :in_development)
              visit admin_form_path(form)
              click_on "Archive this form"
              page.driver.browser.switch_to.alert.accept
            end

            it "display 'Archived' flash message" do
              expect(page).to have_content("Archived")
              expect(page).to have_content('Publish to make it "live."')
            end
          end
        end

        context "copy from form info" do
          it "can copy a form" do
            click_on "Copy"
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content("Survey was successfully copied")
          end
        end

        describe "Common Form Elements" do
          context "title" do
            before do
              visit questions_admin_form_path(form)
            end

            it "has inline editable title that can be updated and saved" do
              find(".survey-title-input").set("Updated Form Title")
              find(".survey-title-input").native.send_key :tab
              expect(page).to have_content("survey title saved")
              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find(".survey-title-input")).to have_content("Updated Form Title")
            end

            it "has inline editable instructions textbox that can be updated and saved" do
              within ".fba-instructions" do
                fill_in "instructions", with: "Some <a href=\"#\">HTML Instructions</a> go here"
                find(".instructions").native.send_key :tab
                expect(page).to have_content("go here")
                expect(page).to have_link("HTML Instructions")
                expect(page).to have_content("saved")
              end
              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find(".fba-instructions")).to have_link("HTML Instructions")
              expect(find(".fba-instructions")).to have_content("go here")
            end

            it "has inline editable disclaimer text textbox that can be updated and saved" do
              fill_in("disclaimer-text", with: "Disclaaaaaaaimer! with <a href=\"#\">a new link</a>")
              within ".touchpoints-form-disclaimer" do
                find("#disclaimer_text").native.send_key :tab
                expect(page).to have_content("saved")
                expect(find("#disclaimer_text-show")).to have_content("Disclaaaaaaaimer!")
                expect(find("#disclaimer_text-show")).to have_link("a new link")
              end

              # and persists after refresh
              visit questions_admin_form_path(form)
              expect(find("#disclaimer_text-show")).to have_content("Disclaaaaaaaimer!")
              expect(find("#disclaimer_text-show")).to have_link("a new link")
            end
          end
        end

        describe "Submission Export button" do
          context "when no Submissions exist" do
            before do
              visit responses_admin_form_path(form)
            end

            it "display text conveying there are no responses yet" do
              expect(page).to have_content("Responses (0)")
              expect(page).to have_content("Export is not available.")
              expect(page).to have_content("This Form has yet to receive any Responses.")
              expect(page).to_not have_link("Export Responses to CSV")
            end
          end

          context "when Submissions exist" do
            let!(:submission) { FactoryBot.create(:submission, form: form)}

            before do
              visit responses_admin_form_path(form)
            end

            it "display table list of Responses and Export CSV button link" do
              within("table.submissions") do
                expect(page).to have_content(submission.answer_01)
              end
              expect(page).to have_link("Export All Responses to CSV")
            end
          end
        end

        describe "/admin/forms/:uuid/example" do
          describe "Form with `inline` delivery_method" do
            let(:form2) { FactoryBot.create(:form, :open_ended_form, :inline, organization: organization, user: user)}

            before "/admin/forms/:uuid/example" do
              visit example_admin_form_path(form2)
            end

            it "can complete then submit the inline Form and see a Success message" do
              fill_in "answer_01", with: "We the People of the United States, in Order to form a more perfect Union..."
              click_on "Submit"

              expect(page).to have_content("Success")
              expect(page).to have_content("Thank you. Your feedback has been received.")
            end
          end

          context "With load_css" do
            let(:form3) { FactoryBot.create(:form, :open_ended_form, :inline, organization: organization, user: user, load_css: true)}

            before "/admin/forms/:uuid/example" do
              visit example_admin_form_path(form3)
            end

            it "can complete then submit the inline Form and see a Success message" do
              fill_in "answer_01", with: "We the People of the United States, in Order to form a more perfect Union..."
              click_on "Submit"

              expect(page).to have_content("Success")
              expect(page).to have_content("Thank you. Your feedback has been received.")
            end
          end
        end
      end

      describe "/admin/forms/:uuid/notifications" do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin)}
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }

        before do
          visit notifications_admin_form_path(form)
          expect(find_field('form_notification_emails').value).to eq(form.notification_emails)
          fill_in("form_notification_emails", with: "new@email.gov")
          click_on "Update Survey"
        end

        it "updates successfully" do
          expect(page).to have_content("Survey was successfully updated.")
          visit notifications_admin_form_path(form)
          expect(find("input[type='text']").value).to eq("new@email.gov")
        end
      end

      context "Edit Form page" do
        let!(:form) { FactoryBot.create(:form, :custom, organization: organization, user: admin) }
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }

        before do
          login_as(admin)
          visit edit_admin_form_path(form)
        end

        describe "editing a Form definition" do
          before do
            fill_in "form_name", with: "Updated Form Name"
            click_on "Update Survey"
          end

          it "can edit existing Form" do
            expect(page).to have_content("Survey was successfully updated.")
            expect(page.current_path).to eq(admin_form_path(form))
            expect(page).to have_content("Updated Form Name")
          end
        end

        describe "modifying Form Sections" do
          it "cannot delete the only remaining form section" do
            expect(page).to_not have_content("Delete Form Section")
          end
        end

        describe "delete a Form" do
          context "with no responses" do
            before do
              click_on "Delete Survey"
              page.driver.browser.switch_to.alert.accept
            end

            it "can delete existing Form" do
              expect(page).to have_content("Survey was successfully destroyed.")
            end
          end

          context "with responses" do
            let!(:submission) { FactoryBot.create(:submission, form: form)}

            before do
              click_on "Delete Survey"
              page.driver.browser.switch_to.alert.accept
            end

            it "cannot delete existing Form" do
              expect(page).to have_content("This form cannot be deleted because it has responses")
            end
          end
        end

        context "Form Sections" do
          before do
            login_as(admin)
          end

          describe "adding Form Sections" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Section"
            end

            it "displays /admin/forms/:id/form_sections/new" do
              expect(page).to have_content("New Section")
            end

          end

          describe "editing Form Sections" do
            before do
              visit questions_admin_form_path(form)
            end

            describe "FormSection.title" do
              before do
                find(".section-title").click
              end

              it "displays editable input that can be updated and saved" do
                expect(find(".section-title").text).to eq("Page 1")
                find(".section-title").set("New Form Section Title")
                find(".section-title").native.send_keys :tab

                expect(find(".section-title").text).to eq("New Form Section Title")
                # and persists after refresh
                visit questions_admin_form_path(form)
                expect(find(".section-title").text).to eq("New Form Section Title")
              end
            end
          end

          describe "delete Form Sections" do
            before do
              visit questions_admin_form_path(form)
            end

            it "defaults to 1 section" do
              expect(find_all(".section").size).to eq(1)
            end

            describe "with at least 2 Sections" do
              let!(:form_section2) { FactoryBot.create(:form_section, form: form) }

              before do
                visit questions_admin_form_path(form)
              end

              it "display successful flash message" do
                expect(find_all(".section").size).to eq(2)
                within(first(".section")) do
                  click_on "Delete Section"
                  page.driver.browser.switch_to.alert.accept
                end
                expect(page.current_path).to eq(questions_admin_form_path(form))
                expect(page).to have_content("Form section was successfully deleted.")
                expect(find_all(".section").size).to eq(1)
              end
            end
          end
        end

        describe "character limit field" do
          before do
            visit questions_admin_form_path(form)
            click_on "Add Question"
          end

          it 'shows character limit field' do
            choose "question_question_type_text_field"
            expect(page).to have_content("Character limit")
            choose "question_question_type_textarea"
            expect(page).to have_content("Character limit")
          end

          it 'hides character limit field' do
            choose "question_question_type_radio_buttons"
            expect(page).not_to have_content("Character limit")
            choose "question_question_type_dropdown"
            expect(page).not_to have_content("Character limit")
            choose "question_question_type_checkbox"
            expect(page).not_to have_content("Character limit")
          end
        end

        describe "adding Questions" do
          describe "help text and placeholder text" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              fill_in "question_text", with: "New Test Question"
              choose "question_question_type_text_field"
              fill_in "question_help_text", with: "Additional help text for this question"
              fill_in "question_placeholder_text", with: "Placeholder text for this question"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "persist and display help text" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Test Question")
                expect(page).to have_content("Additional help text for this question")
                expect(page).to have_css("input#answer_01[type='text']")
              end
            end

            it "persist and display placeholder text" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Test Question")
                expect(page).to have_css("input#answer_01[type='text']")
                expect(find("#answer_01")["placeholder"]).to eq("Placeholder text for this question")
              end
            end
          end

          describe "add a Text Field question" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              fill_in "question_text", with: "New Test Question"
              choose "question_question_type_text_field"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "can add a Text Field Question" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Test Question")
                expect(page).to have_css("input[type='text']")
              end
            end
          end

          describe "add a Text Phone Field question" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              fill_in "question_text", with: "New Test Question"
              choose "question_question_type_text_phone_field"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "can add a Text Field Question" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Test Question")
                expect(page).to have_css("input[type='tel']")
              end
            end
          end

          describe "add a Text Area question" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              fill_in "question_text", with: "New Text Area"
              choose "question_question_type_textarea"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "can add a Text Area question" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Text Area")
                expect(page).to have_css("textarea")
              end
            end
          end

          describe "add a Radio Buttons question" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              fill_in "question_text", with: "New Test Question Radio Buttons"
              choose "question_question_type_radio_buttons"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "can add a Text Field Question" do
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder .question" do
                expect(page).to have_content("New Test Question Radio Buttons")
                # Radio buttons won't be showing yet. Because they need to be added.
              end
            end
          end

          describe "add a Checkbox question" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              choose "question_question_type_checkbox"
              select("answer_01", from: "question_answer_field")
              click_on "Update Question"
            end

            it "can add a Checkbox Question" do
              expect(page).to have_link("Add Checkbox Option")
            end

            it "can cancel a Checkbox Question" do
              click_on "Add Checkbox Option"
              expect(page).to have_content("New Question Option")
              click_on "Cancel"
              expect(page.current_path).to eq(admin_form_questions_path(form))
              expect(page).not_to have_content("New Question Option")
            end
          end

          describe "#edit question and cancel" do
            let!(:first_question) { FactoryBot.create(:question, form: form, form_section: form.form_sections.first, answer_field: :answer_01) }

            before do
              visit questions_admin_form_path(form)
              page.execute_script "$('.question-menu-action').trigger('mouseover')"
              expect(page).to have_selector('.dropdown-content',visible: true)
              click_on "Edit"
              expect(page.current_path).to eq(questions_admin_form_path(form))
              expect(page).to have_content("Cancel")
            end

            it "removes the edit form on cancel" do
              click_on "Cancel"
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder" do
                expect(page).not_to have_content("Cancel")
              end
            end

            it "does not persist change on cancel" do
              fill_in "question_text", with: "Canceled question"
              click_on "Cancel"
              expect(page.current_path).to eq(questions_admin_form_path(form))
              within ".form-builder" do
                expect(page).not_to have_content("Canceled question")
              end
            end
          end

          describe "answer display" do
            let!(:first_question) { FactoryBot.create(:question, form: form, form_section: form.form_sections.first, answer_field: :answer_01) }

            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
            end

            it "displays answers that are not assigned to other Questions" do
              expect(find("#question_answer_field")).to_not have_content("answer_01")
              expect(find("#question_answer_field")).to have_content("answer_02")
            end
          end

          context "Dropdown Question" do
            describe "#create" do
              before do
                visit questions_admin_form_path(form)
                click_on "Add Question"
                expect(page.current_path).to eq(questions_admin_form_path(form))
                choose "question_question_type_dropdown"
                # select("dropdown", from: "question_question_type")
                fill_in "question_text", with: "New dropdown field"
                select("answer_01", from: "question_answer_field")
                click_on "Update Question"
                expect(page).to have_css("#answer_01")
              end

              it "can add a dropdown Question" do
                expect(page.current_path).to eq(questions_admin_form_path(form))
                within ".form-builder" do
                  expect(page).to have_content("New dropdown field")
                  # Radio buttons won't be showing yet. Because they need to be added.
                end
              end

              describe "#edit" do
                before do
                  visit questions_admin_form_path(form)
                  page.execute_script "$('.question-menu-action').trigger('mouseover')"
                  expect(page).to have_selector('.dropdown-content',visible: true)
                  click_on "Edit"
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  expect(find_field('question_text').value).to eq 'New dropdown field'
                end

                it "add a Question Option for a dropdown" do
                  fill_in "question_text", with: "Updated question text"
                  click_on "Update Question"

                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  within ".form-builder" do
                    expect(page).to have_content("Updated question text")
                  end
                end
              end

              describe "Question Options for a dropdown" do
                before do
                  visit questions_admin_form_path(form)
                  click_on "Add Dropdown Option"
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  fill_in "question_option_text", with: "Dropdown option #1"
                  # Create the option
                  click_on "Create Question option"
                end

                it "add a Question Option for a dropdown" do
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  expect(page).to have_content("Dropdown option #1")

                  within ".form-builder .question-options .question-option[data-id='#{QuestionOption.last.id}']" do
                    expect(page).to have_content("Dropdown option #1")
                    expect(page).to have_css(".delete.button")
                  end

                  # Update the option
                  within(".question-options") do
                    find_all(".question-option .question-option-view").first.click
                    fill_in "question_option_text", with: "Edited Question Option Text"
                    fill_in "question_option_value", with: "100"
                    find(".fa-save").click
                  end
                  expect(page).to have_content("Edited Question Option Text (100)")
                end

                it "will prevent updating a question option with no text" do
                  click_on "Add Dropdown Option"
                  expect(page).to have_content("New Question Option")
                  click_on "Create Question option"
                  page.driver.browser.switch_to.alert.accept
                  expect(page).to have_button("Create Question option")
                end

                it "can cancel a Dropdown Question option" do
                  click_on "Add Dropdown Option"
                  expect(page).to have_content("New Question Option")
                  click_on "Cancel"
                  expect(page.current_path).to eq(admin_form_questions_path(form))
                  expect(page).not_to have_content("New Question Option")
                end
              end
            end
          end

          context "States Dropdown Question" do
            describe "#create" do
              before do
                visit questions_admin_form_path(form)
                click_on "Add Question"
                expect(page.current_path).to eq(questions_admin_form_path(form))
                choose "question_question_type_states_dropdown"
                fill_in "question_text", with: "New dropdown field"
                select("answer_01", from: "question_answer_field")
                click_on "Update Question"
                expect(page).to have_css("#answer_01")
              end

              it "can add a dropdown Question" do
                expect(page.current_path).to eq(questions_admin_form_path(form))
                within ".form-builder" do
                  expect(page).to have_content("New dropdown field")
                end
              end

              describe "#edit" do
                before do
                  visit questions_admin_form_path(form)
                  page.execute_script "$('.question-menu-action').trigger('mouseover')"
                  expect(page).to have_selector('.dropdown-content',visible: true)
                  click_on "Edit"
                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  expect(find_field('question_text').value).to eq 'New dropdown field'
                end

                it "add a Question Option for a dropdown" do
                  fill_in "question_text", with: "Updated question text"
                  click_on "Update Question"

                  expect(page.current_path).to eq(questions_admin_form_path(form))
                  within ".form-builder" do
                    expect(page).to have_content("Updated question text")
                  end
                end
              end
            end
          end

          describe "add a text display element" do
            before do
              visit questions_admin_form_path(form)
              click_on "Add Question"
              expect(page.current_path).to eq(questions_admin_form_path(form))
              choose "question_question_type_text_display"
              fill_in "question_text", with: 'Some custom <a href="#">html</a>'
              select("answer_20", from: "question_answer_field")
              click_on "Update Question"
            end

            it "display text display element with html" do
              within ".form-builder .question" do
                expect(page).to have_content("Some custom")
                expect(page).to have_link("html")
              end
            end
          end

        end

        describe "deleting Questions" do
          let(:form2) { FactoryBot.create(:form, :custom, organization: organization, user: admin) }
          let(:form_section2) { FactoryBot.create(:form_section, form: form2) }
          let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }
          let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }

          context "with Form Manager permissions" do
            before do
              visit questions_admin_form_path(form2)
              page.execute_script "$('.question-menu-action').trigger('mouseover')"
              expect(page).to have_selector('.dropdown-content',visible: true)
            end

            it "display the Delete Question button" do
              expect(page).to have_link("Delete")
            end
          end
        end

        describe "adding Question Options" do
          describe "add Radio Button options" do
            let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }

            before do
              visit questions_admin_form_path(form)
              click_on "Add Radio Button Option"
              expect(page).to have_content("New Question Option")
              expect(page).to have_selector('.well #question_option_text:focus')
              expect(page).to have_content("for the question: #{radio_button_question.text}")
              expect(page).to have_content("with a question_type of: radio_buttons")
            end

            it "Question Option value is populated with Question Option name by default, on outfocus" do
              fill_in("question_option_text", with: "New Test Radio Option")
              page.evaluate_script("$('#question_option_value').focus()")
              expect(find("#question_option_value").value).to eq("New Test Radio Option")
            end

            it "create a Radio Button option" do
              fill_in("question_option_text", with: "New Test Radio Option")
              fill_in("question_option_value", with: "123")
              click_on("Create Question option")

              expect(page).to have_content("New Test Radio Option")
              within ".form-builder .question-options .question-option[data-id='#{QuestionOption.last.id}']" do
                expect(all("label").last).to have_content("New Test Radio Option")
              end
            end

            it "can cancel a Radio Button question" do
              expect(page).to have_content("New Question Option")
              click_on "Cancel"
              expect(page.current_path).to eq(admin_form_questions_path(form))
              expect(page).not_to have_content("New Question Option")
            end
          end

          xdescribe "adding Checkbox options" do
          end

          xdescribe "adding Dropdown options" do
          end
        end

        describe "editing Question Options" do
          let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: admin) }

          describe "edit Radio Button option" do
            let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }
            let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

            before do
              visit questions_admin_form_path(form)
              within(".question-options") do
                find_all(".question-option .question-option-view").first.click
                fill_in "question_option_text", with: "Edited Question Option Text"
                fill_in "question_option_value", with: "100"
                find(".fa-save").click
              end
            end

            it "display the updated text and custom value" do
              expect(page).to have_content("Edited Question Option Text (100)")
            end
          end

          describe "edit Dropdown option" do
            let!(:dropdown_question) { FactoryBot.create(:question, :with_dropdown_options, form: form, form_section: form.form_sections.first) }
            let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: admin) }

            before do
              visit questions_admin_form_path(form)
              find_all(".question-option-view").first.click
              fill_in "question_option_text", with: "Edited Question Option Text"
              fill_in "question_option_value", with: "100"
              find(".button.form-save-question-option").click
            end

            it "display updated text and value" do
              expect(page).to have_content("Edited Question Option Text (100)")
              expect(find_all(".question-option-view").first).to have_content("Edited Question Option Text (100)")
            end
          end

        end

      end
    end
  end

  context "form owner with Form Manager permissions" do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:form) { FactoryBot.create(:form, :custom, organization: organization, user: user) }

    let(:another_organization) { FactoryBot.create(:organization, :another) }
    let(:another_user) { FactoryBot.create(:user, email: "user@another.gov", organization: another_organization) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: another_user) }

    before do
      login_as(another_user)
      visit edit_admin_form_path(form)
    end

    it "can edit form" do
      expect(page.current_path).to eq(edit_admin_form_path(form))
      expect(page).to have_content("Editing Survey")
    end

    it "regression: edit does not set the Organization to the user's org" do
      click_on "Update Survey"
      expect(page).to have_content("Organization")
      expect(page).to have_link("Example.gov")
    end

    describe "can delete a Form" do
      context "with no responses" do
        before do
          click_on "Delete Survey"
          page.driver.browser.switch_to.alert.accept
        end

        it "can delete existing Form" do
          expect(page).to have_content("Survey was successfully destroyed.")
        end
      end

      context "with responses" do
        let!(:submission) { FactoryBot.create(:submission, form: form)}

        before do
          click_on "Delete Survey"
          page.driver.browser.switch_to.alert.accept
        end

        it "cannot delete existing Form" do
          expect(page).to have_content("This form cannot be deleted because it has responses")
        end
      end
    end
  end

  context "user without Form Manager permissions" do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:user2) { FactoryBot.create(:user, organization: organization) }
    let!(:form) { FactoryBot.create(:form, :custom, organization: organization, user: user2) }

    describe "cannot edit the form" do
      before do
        login_as(user)
        visit edit_admin_form_path(form)
      end

      it "redirects to /admin" do
        expect(page.current_path).to eq(admin_root_path)
        expect(page).to have_content("Authorization is Required")
      end
    end
  end

  context "without Form Manager permissions" do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:another_user) { FactoryBot.create(:user, organization: organization) }
    let!(:another_users_form) { FactoryBot.create(:form, :custom, organization: organization, user: another_user) }

    describe "reduced UI features on /edit" do
      before do
        login_as(user)
        visit edit_admin_form_path(another_users_form)
      end

      it "does not see the Delete Question button" do
        expect(page).to_not have_link("Delete")
      end
    end

    describe "insufficient privileges to /permissions" do
      before do
        login_as(user)
        visit permissions_admin_form_path(another_users_form)
      end

      it "is redirected away and shown a message" do
        expect(page).to have_content("Authorization is Required")
        expect(page.current_path).to eq admin_root_path
      end
    end

    describe "insufficient privileges to /questions" do
      before do
        login_as(user)
        visit questions_admin_form_path(another_users_form)
      end

      it "is redirected away and shown a message" do
        expect(page).to have_content("Authorization is Required")
        expect(page.current_path).to eq admin_root_path
      end
    end
  end

  context "as Touchpoints Manager" do
    let(:touchpoints_manager) { FactoryBot.create(:user, organization: organization) }

    before do
      login_as(touchpoints_manager)
    end

    context "#new form page" do
      before do
        visit new_admin_form_path
      end

      describe "create a survey feature" do
        it "Create button is disabled by default" do
          expect(find("input[value='Create Survey']").disabled?).to be(true)
        end
      end

      describe "copy a survey feature" do
        it "Copy button is disabled by default" do
          expect(find("input[value='Copy Survey']").disabled?).to be(true)
        end
      end
    end

    describe "create a form" do
      before do
        visit new_admin_form_path
        fill_in "form_name", with: "New test form name"
        click_on "Create Survey"
      end

      it "arrives at /admin/forms/:uuid/questions" do
        expect(page.current_path).to eq questions_admin_form_path(Form.first)
      end

      context "notification settings" do
        before do
          visit notifications_admin_form_path(Form.first)
        end

        it "set notification_email to the email of the user who creates the form" do
          within ".usa-nav__secondary .user-name" do
            expect(page).to have_content(touchpoints_manager.email)
          end
          expect(find_field('form_notification_emails').value).to eq(touchpoints_manager.email)
        end
      end
    end

    describe "copying a Form" do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: touchpoints_manager) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: touchpoints_manager) }

      before do
        visit admin_forms_path
        within(".float-menu") do
          find("button").click
          find("#extended-nav-section-one-#{form.short_uuid}", visible: true)
        end
      end

      it "conveys the survey was successfully copied" do
        click_link("Copy")
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content("Editing Questions")
        expect(page).to have_content("Copy of #{form.name}")
        expect(page).to have_content("Survey was successfully copied.")
      end
    end

    describe "deleting Questions" do
      let(:form2) { FactoryBot.create(:form, :custom, organization: organization, user: touchpoints_manager) }
      let(:form_section2) { FactoryBot.create(:form_section, form: form2) }
      let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }

      context "with Form Manager permissions" do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, { form: form2, user: touchpoints_manager }) }

        before do
          visit questions_admin_form_path(form2)
          page.execute_script "$('.question-menu-action').trigger('mouseover')"
          expect(page).to have_selector('.dropdown-content',visible: true)
        end

        it "see the delete button, click it, and delete the question" do
          expect(page).to have_css(".question#question_#{form2.id}")
          expect(page).to have_link("Delete")
          click_on("Delete")
          page.driver.browser.switch_to.alert.accept
          expect(page).to_not have_css(".question#question_#{form2.id}")
        end

        describe "update a Touchpoint Form Section" do
          let(:new_title) { "New Form Section Title" }

          before do
            visit edit_admin_form_form_section_path(form_section2.form, form_section2)
            fill_in("form_section[title]", with: new_title)
            click_button "Update Section"
          end

          it "redirect to /admin/forms/:id/edit with a success flash message" do
            expect(page.current_path).to eq(questions_admin_form_path(form_section2.form))
            expect(page).to have_content("Form section was successfully updated.")
            expect(page).to have_content(new_title)
          end
        end

        describe "multiple Touchpoint Form Sections" do
          let(:new_title) { "New Form Section Title" }

          before do
            visit questions_admin_form_path(form_section2.form)
            find_all(".form-add-question").first.click
            fill_in "question_text", with: "Question in Form Section 1"
            select("text_field", from: "question_question_type")
            click_on "Update Question"
            # Select the Add Question button in the 2nd Form Section
            visit questions_admin_form_path(form_section2.form)
            find_all(".form-add-question").last.click
            fill_in "question_text", with: "Question in Form Section 2"
            select("text_field", from: "question_question_type")
            click_on "Update Question"
            visit questions_admin_form_path(form_section2.form)
          end

          it "creates the question in the correct Form Section" do
            within(find_all(".form-section-div").first) do
              expect(page).to have_content("Question in Form Section 1")
            end
            within(find_all(".form-section-div").last) do
              expect(page).to have_content("Question in Form Section 2")
            end
          end
        end
      end
    end

    describe "#export" do
      let(:form_manager) { FactoryBot.create(:user, organization: organization) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: form_manager)}
      let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first, answer_field: :answer_02) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: form) }

      before do
        visit export_admin_form_path(form)
      end

      it "includes form attributes" do
        expect(page).to have_content("form")
        expect(page).to have_content("questions")
        expect(page).to have_content("question_options")
      end
    end
  end

  context "as Response Viewer" do
    # as a Response Viewer
    describe "/admin/forms/:uuid" do
      let(:response_viewer) { FactoryBot.create(:user, organization: organization) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: response_viewer)}
      let!(:user_role) { FactoryBot.create(:user_role, :response_viewer, user: response_viewer, form: form) }

      before do
        login_as(response_viewer)
        visit admin_form_path(form)
      end

      describe "unavailable UI features" do
        it "does not display 'Publish' component" do
          expect(page).not_to have_content("Publish your form")
        end

        it "does not display 'Roles and Permissions' component" do
          expect(page).not_to have_content("Roles & Permissions")
        end
      end

      describe "Submission Export button" do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin)}

        context "when no Submissions exist" do
        end

        context "when Submissions exist" do
          let!(:submission) { FactoryBot.create(:submission, form: form)}

          before do
            visit responses_admin_form_path(form)
          end

          it "display table list of Responses and Export CSV button link" do
            within("table.submissions") do
              expect(page).to have_content(submission.answer_01)
            end
            expect(page).to have_link("Export All Responses to CSV")
          end
        end
      end
    end


    context "user for another Form" do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin)}

      before do
        login_as(user)
      end

      describe "insufficient privileges to /permissions" do
        before do
          visit permissions_admin_form_path(form)
        end

        it "is redirected away and shown a message" do
          expect(page).to have_content("Authorization is Required")
          expect(page.current_path).to eq admin_root_path
        end
      end

      describe "insufficient privileges to /questions" do
        before do
          visit questions_admin_form_path(form)
        end

        it "is redirected away and shown a message" do
          expect(page).to have_content("Authorization is Required")
          expect(page.current_path).to eq admin_root_path
        end
      end
    end

    describe "/admin/forms/:uuid/example" do
      describe "Form with `inline` delivery_method" do
        let(:form2) { FactoryBot.create(:form, :open_ended_form, :inline, organization: organization, user: admin)}

        before "/admin/forms/:uiid/example" do
          login_as(admin)
          visit example_admin_form_path(form2)
        end

        it "can complete then submit the inline Form and see a Success message" do
          fill_in "answer_01", with: "We the People of the United States, in Order to form a more perfect Union..."
          click_on "Submit"
          expect(page).to have_content("Success")
          expect(page).to have_content("Thank you. Your feedback has been received.")
        end
      end
    end
  end

  context "as non-logged in User" do
    let!(:form_template) { FactoryBot.create(:form, organization: organization, user: admin, template: true, aasm_state: :in_development) }

    describe "cannot access forms" do
      before do
        visit admin_forms_path
      end

      it "display flash message on homepage" do
        expect(page.current_path).to eq(index_path)
        expect(page).to have_content("Authorization is Required")
      end
    end

    describe "cannot preview a form template" do
      before do
        visit submit_touchpoint_path(form_template)
      end

      it "cannot preview a form template" do
        expect(page.current_path).to eq(index_path)
        expect(page).to have_content("Form is not currently deployed.")
      end
    end
  end

  describe "/invite" do
    let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin)}

    before do
      login_as(admin)
    end

    context "with a valid email" do
      before do
        visit permissions_admin_form_path(form)
      end

      it "sends an invite to the designated user" do
        fill_in("user[refer_user]", with: "newuser@domain.gov")
        click_on "Invite User"
        expect(page).to have_content("Invite sent to newuser@domain.gov")
        expect(page.current_path).to eq(permissions_admin_form_path(form))
      end
    end

    context "with an invalid email" do
      before do
        visit permissions_admin_form_path(form)
      end

      it "shows an alert when the email address is not provided" do
        fill_in("user[refer_user]", with: "")
        click_on "Invite User"
        expect(page).to have_content("Please enter a valid .gov or .mil email address")
        expect(page.current_path).to eq(permissions_admin_form_path(form))
      end

      it "shows a gov-specific user alert when the email address is not a valid email" do
        fill_in("user[refer_user]", with: "test")
        click_on "Invite User"
        expect(page).to have_content("Please enter a valid .gov or .mil email address")
        expect(page.current_path).to eq(permissions_admin_form_path(form))
      end

      context "when using GitHub for oAuth" do
        before do
          ENV["GITHUB_CLIENT_ID"] = "something"
        end

        it "shows a generic user alert when the email address is not a valid email" do
          fill_in("user[refer_user]", with: "test")
          click_on "Invite User"
          expect(page).to have_content("Please enter a valid email address")
          expect(page.current_path).to eq(permissions_admin_form_path(form))
        end
      end

      it "shows an alert when the email address already exists" do
        fill_in("user[refer_user]", with: user.email)
        click_on "Invite User"
        expect(page).to have_content("User with email #{user.email} already exists")
        expect(page.current_path).to eq(permissions_admin_form_path(form))
      end
    end
  end
end
