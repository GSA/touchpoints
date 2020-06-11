require 'rails_helper'

feature "Forms", js: true do
  let(:future_date) {
    Time.now + 3.days
  }
  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  context "as Admin" do
    describe "/admin/forms" do
      before do
        login_as(admin)
      end

      context "with multiple (3) forms" do
        let!(:form) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form2) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form3) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form_template) { FactoryBot.create(:form, organization: organization, user: user, template: true, aasm_state: :in_development)}
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }
        let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }
        let!(:user_role3) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form3) }

        before do
          visit admin_forms_path
        end

        context "Form Templates" do
          describe "can preview a template" do
            before do
              within ".form-templates" do
                click_on "Preview Template"
                # Opens in new window
                visit submit_touchpoint_path(form_template)
              end
            end

            it "can preview a template" do
              within_window(windows.last) do
                expect(page.current_path).to eq(submit_touchpoint_path(form_template))
                expect(page).to have_content(form_template.title)
              end
            end
          end

          describe "can edit a template" do
            before do
              within ".form-templates" do
                click_on "Edit Template"
              end
            end

            it "can edit a form template" do
              expect(page.current_path).to eq(edit_admin_form_path(form_template))
              expect(page).to have_content("Editing Form")
              expect(form_template.template).to eq(true)
              fill_in("form_notes", with: "Updated notes text")
              click_on "Update Form"
              expect(page).to have_content("Form was successfully updated.")
              expect(page.current_path).to eq(admin_form_path(form_template))
              expect(page).to have_content("Updated notes text")
            end
          end
        end

        it "display forms in a table" do
          rows = page.all("tr")
          expect(rows.length).to eq 4 # 3 forms, plus 1 header row
          expect(rows[1]).to have_content("1") # id
          expect(rows[1]).to have_link(form.name)
          expect(rows[1]).to have_content("0") # submissions
        end

        it "display 'new form' button" do
          expect(page).to have_link("New Form")
        end

        it "click through to New Form Page" do
          expect(page.current_path).to eq(admin_forms_path)
          click_on "New Form"
          expect(page.current_path).to eq(new_admin_form_path)
        end
      end
    end

    describe "/admin/forms/new" do
      before do
        login_as(admin)
      end

      let(:new_form) { FactoryBot.create(:form, :custom, organization: organization, user: admin) }

      describe "new touchpoint hosted form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          select(new_form.organization.name, from: "form_organization_id")
          fill_in "form_name", with: new_form.name
          click_on "Create Form"
        end

        it "redirect to /form/:uuid with a success flash message" do
          expect(page).to have_content("Form was successfully created.")
          @form = Form.last
          expect(page.current_path).to eq(edit_admin_form_path(@form))
          expect(find_field('form_name').value).to eq new_form.name

          expect(@form.user).to eq admin
          expect(@form.organization).to eq admin.organization
          expect(@form.title).to eq new_form.name

          expect(find_field('form_modal_button_text').value).to eq(I18n.t('form.help_improve'))
          expect(find_field('form_success_text').value).to eq(I18n.t('form.submit_thankyou'))

          # This should work, but is not. Next line gets the job done.
          # expect(page).to have_select("form_user_id", selected: "admin@example.gov")
          expect(page.find("#form_user_id").text).to eq "admin@example.gov"
        end
      end

      describe "new inline form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          select(new_form.organization.name, from: "form_organization_id")
          fill_in "form_name", with: new_form.name
          click_on "Create Form"
        end

        it "redirect to /form/:uuid with a success flash message" do
          expect(page).to have_content("Form was successfully created.")
          @form = Form.last
          expect(page.current_path).to eq(edit_admin_form_path(@form))
          expect(find_field('form_name').value).to eq new_form.name
          expect(page.find("#form_user_id").text).to eq "admin@example.gov"
        end
      end

      describe "Form model validations" do
        let(:existing_form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, omb_approval_number: nil, expiration_date: nil)}

        describe "missing OMB Approval Number" do
          before "user tries to update a Touchpoint" do
            visit edit_admin_form_path(existing_form)

            fill_in("form[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
            click_button "Update Form"
          end

          it "display a flash message about missing OMB Approval Number" do
            within(".usa-alert--error") do
              expect(page).to have_content("Omb approval number required with an Expiration Date")
            end
          end
        end

        describe "missing Expiration Date" do
          before "user tries to update a Touchpoint" do
            visit edit_admin_form_path(existing_form)

            fill_in("form[omb_approval_number]", with: 1234)
            click_button "Update Form"
          end

          it "display a flash message about missing Expiration Date" do
            within(".usa-alert--error") do
              expect(page).to have_content("Expiration date required with an OMB Number")
            end
          end
        end
      end
    end

    # as a Form Manager
    describe "/admin/forms/:uuid" do
      let(:user) { FactoryBot.create(:user, organization: organization) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user)}
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: user, form: form) }

      before do
        login_as(user)
        visit admin_form_path(form)
      end

      context "for :in_development touchpoint" do
        describe "Publishing" do
          before do
            form.update_attribute(:aasm_state, :in_development)
            visit admin_form_path(form)
            click_on "Publish"
            page.driver.browser.switch_to.alert.accept
          end

          it "display 'Published' flash message" do
            expect(page).to have_content("Published")
            expect(page).to have_content("Roles & Permissions")
          end
        end
      end

      describe "Submission Export button" do
        context "when no Submissions exist" do
        end

        context "when Submissions exist" do
          let!(:submission) { FactoryBot.create(:submission, form: form)}

          before do
            visit admin_form_path(form)
          end

          it "display table list of Responses and Export CSV button link" do
            within("table.submissions") do
              expect(page).to have_content(submission.answer_01)
            end
            expect(page).to have_link("Export Responses to CSV")
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
        login_as(admin)
        visit notifications_admin_form_path(form)
        expect(find_field('form_notification_emails').value).to eq(form.notification_emails)
        fill_in("form_notification_emails", with: "new@email.gov")
        click_on "Update Form"
      end

      it "updates successfully" do
        expect(page).to have_content("Form was successfully updated.")
        expect(page).to have_content("new@email.gov")
      end
    end

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
        context "when no Submissions exist" do
        end

        context "when Submissions exist" do
          let!(:submission) { FactoryBot.create(:submission, form: form)}

          before do
            visit admin_form_path(form)
          end

          it "display table list of Responses and Export CSV button link" do
            within("table.submissions") do
              expect(page).to have_content(submission.answer_01)
            end
            expect(page).to have_link("Export Responses to CSV")
          end
        end
      end

      describe "/admin/forms/:uuid/example" do
        describe "Form with `inline` delivery_method" do
          let(:form2) { FactoryBot.create(:form, :open_ended_form, :inline, organization: organization, user: admin)}

          before "/admin/forms/:uiid/example" do
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

    context "Edit Form page" do
      let!(:form) { FactoryBot.create(:form, :custom, organization: organization, user: admin) }

      before do
        login_as(admin)
        visit edit_admin_form_path(form)
      end

      describe "editing a Form definition" do
        before do
          fill_in "form_name", with: "Updated Form Name"
          fill_in "form_title", with: "Updated Title"
          click_on "Update Form"
        end

        it "can edit existing Form" do
          expect(page).to have_content("Form was successfully updated.")
          expect(page.current_path).to eq(admin_form_path(form))
          expect(page).to have_content("Updated Form Name")
          expect(page).to have_content("Updated Title")
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
            click_on "Delete Form"
            page.driver.browser.switch_to.alert.accept
          end

          it "can delete existing Form" do
            expect(page).to have_content("Form was successfully destroyed.")
          end
        end

        context "with responses" do
          let!(:submission) { FactoryBot.create(:submission, form: form)}

          before do
            click_on "Delete Form"
            page.driver.browser.switch_to.alert.accept
          end

          it "cannot delete existing Form" do
            expect(page).to have_content("This form cannot be deleted because it has responses")
          end
        end
      end

      describe "adding Form Sections" do
        before do
          visit edit_admin_form_path(form)
          click_on "Add Form Section"
        end

        it "displays /admin/forms/:id/form_sections/new" do
          expect(page).to have_content("New Form Section")
        end

        describe "add Form Section" do
          before do
            fill_in("form_section_title", with: "Test Form Section Title")
            select("1", from: "form_section_position")
            click_on "Create Form section"
          end

          it "create Form Section successfully" do
            expect(page).to have_content("Form section was successfully created.")
          end
        end
      end

      describe "adding Questions" do
        describe "add a Text Field question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add Question"
            expect(page).to have_content("New Question")
            fill_in "question_text", with: "New Test Question"
            select("text_field", from: "question_question_type")
            select("answer_01", from: "question_answer_field")
            select(form.form_sections.first.title, from: "question_form_section_id")
            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "can add a Text Field Question" do
            expect(page).to have_content("Question was successfully created.")
            expect(page.current_path).to eq(edit_admin_form_path(form))
            within ".form-builder .question" do
              expect(page).to have_content("New Test Question")
              expect(page).to have_css("input[type='text']")
            end
          end
        end

        describe "add a Text Area question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add Question"
            expect(page).to have_content("New Question")
            fill_in "question_text", with: "New Text Area"
            select("textarea", from: "question_question_type")
            select("answer_01", from: "question_answer_field")
            select(form.form_sections.first.title, from: "question_form_section_id")
            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "can add a Text Area question" do
            expect(page).to have_content("Question was successfully created.")
            expect(page.current_path).to eq(edit_admin_form_path(form))
            within ".form-builder .question" do
              expect(page).to have_content("New Text Area")
              expect(page).to have_css("textarea")
            end
          end
        end

        describe "add a Radio Buttons question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add Question"
            expect(page).to have_content("New Question")
            fill_in "question_text", with: "New Test Question Radio Buttons"
            select("radio_buttons", from: "question_question_type")
            select("answer_01", from: "question_answer_field")
            select(form.form_sections.first.title, from: "question_form_section_id")

            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "can add a Text Field Question" do
            expect(page).to have_content("Question was successfully created.")
            expect(page.current_path).to eq(edit_admin_form_path(form))
            within ".form-builder .question" do
              expect(page).to have_content("New Test Question Radio Buttons")
              # Radio buttons won't be showing yet. Because they need to be added.
            end
          end
        end

        describe "add a Checkbox question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add Question"
            expect(page.current_path).to eq(new_admin_form_question_path(form))
            expect(page).to have_content("New Question")
            fill_in "checkbox", with: "New Test Question Radio Buttons"
            select("radio_buttons", from: "question_question_type")
            select("answer_01", from: "question_answer_field")

            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          xit "can add a Checkbox Question" do
            expect(page).to have_content("Question was successfully created.")
            within ".form-preview .question" do
              # expect(page).to have_content("New Test Question Radio Buttons")
              # Radio buttons won't be showing yet. Because they need to be added.
            end
          end
        end

        context "Dropdown Question" do
          describe "#create" do
            before do
              visit edit_admin_form_path(form)
              click_on "Add Question"
              expect(page.current_path).to eq(edit_admin_form_path(form))
              expect(page).to have_content("New Question")
              select("dropdown", from: "question_question_type")
              fill_in "question_text", with: "New dropdown field"
              select("answer_01", from: "question_answer_field")

              expect(find_field('question_position').value).to eq '1'
              click_on "Create Question"
            end

            it "can add a dropdown Question" do
              expect(page).to have_content("Question was successfully created.")
              expect(page.current_path).to eq(edit_admin_form_path(form))
              within ".form-builder" do
                expect(page).to have_content("New dropdown field")
                # Radio buttons won't be showing yet. Because they need to be added.
              end
            end

            describe "#edit" do
              before do
                visit edit_admin_form_path(form)
                click_on "Edit Question"
                expect(page.current_path).to eq(edit_admin_form_path(form))
                expect(page).to have_content("Editing Question")
                expect(find_field('question_text').value).to eq 'New dropdown field'
              end

              it "add a Question Option for a dropdown" do
                fill_in "question_text", with: "Updated question text"
                click_on "Update Question"

                expect(page).to have_content("Question was successfully updated.")
                expect(page.current_path).to eq(edit_admin_form_path(form))
                within ".form-builder" do
                  expect(page).to have_content("1. Updated question text")
                end
              end
            end

            describe "Question Options for a dropdown" do
              before do
                visit edit_admin_form_path(form)
                click_on "Add Dropdown Option"
                expect(page.current_path).to eq(edit_admin_form_path(form))
                expect(page).to have_content("New Question")
                fill_in "question_option_text", with: "Dropdown option #1"
                fill_in "question_option_value", with: "value1"
                expect(find_field('question_option_position').value).to eq '1'
                click_on "Create Question option"
              end

              it "add a Question Option for a dropdown" do
                expect(page).to have_content("Question option was successfully created.")
                expect(page.current_path).to eq(edit_admin_form_path(form))
                within ".form-builder" do
                  expect(page).to have_content("Dropdown option #1")
                  expect(page).to have_link("Edit")
                end
              end
            end
          end
        end

        describe "add a text display element" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add Question"
            expect(page.current_path).to eq(edit_admin_form_path(form))
            expect(page).to have_content("New Question")

            select("text_display", from: "question_question_type")
            fill_in "question_text", with: 'Some custom <a href="#">html</a>'
            select("answer_20", from: "question_answer_field")
            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "display text display element with html" do
            expect(page).to have_content("Question was successfully created.")
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
            visit edit_admin_form_path(form2)
          end

          it "display the Delete Question button" do
            expect(page).to have_link("Delete Question")
          end
        end
      end

      describe "adding Question Options" do
        describe "add Radio Button options" do
          let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }

          before do
            visit edit_admin_form_path(form)
            click_on "Add Radio Button Option"
            expect(page).to have_content("New Question Option")
            expect(page).to have_content("for the question: #{radio_button_question.text}")
            expect(page).to have_content("with a question_type of: radio_buttons")
            expect(page).to have_content("on the form #{form.name}")
          end

          it "create a Radio Button option" do
            fill_in("question_option_text", with: "New Test Radio Option")
            fill_in("question_option_value", with: "123")
            click_on("Create Question option")
            expect(page).to have_content("Question option was successfully created.")
            within ".form-section-div" do
              expect(all("label").last).to have_content("New Test Radio Option")
            end
          end
        end

        xdescribe "adding Checkbox options" do
        end

        xdescribe "adding Dropdown options" do
        end
      end

      describe "click through to edit Question Option" do
        describe "edit Radio Button option" do
          let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }
          let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

          before do
            visit edit_admin_form_path(form)

            within (".question") do
              within all(".usa-checkbox").first do
                click_on "Edit"
              end
            end
          end

          it "click through to Edit page" do
            expect(page).to have_content("Editing Question Option")
            expect(find_field("question_option_text").value).to eq(radio_button_option.text)
          end
        end
      end

      describe "editing Question Options" do
        describe "edit Radio Button option" do
          let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }
          let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

          before do
            visit edit_admin_form_question_question_option_path(form, radio_button_question, radio_button_option)
            fill_in "question_option_text", with: "Edited Question Option Text"
            fill_in "question_option_value", with: "100"
            click_on "Update Question option"
          end

          it "click through to Edit page" do
            expect(page).to have_content("Question option was successfully updated.")
            within (".question") do
              expect(page).to have_content("Edited Question Option Text")
            end

            # Ensure other (non UI-visible) data persists
            visit edit_admin_form_question_question_option_path(form, radio_button_question, radio_button_option)
            expect(page.find_field("question_option_text").value).to eq("Edited Question Option Text")
            expect(page.find_field("question_option_value").value).to eq("100")
          end
        end
      end

    end

  end

  context "form owner with Form Manager permissions" do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:form) { FactoryBot.create(:form, :custom, organization: organization, user: user) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: user) }

    before do
      login_as(user)
      visit edit_admin_form_path(form)
    end

    it "can edit form" do
      expect(page.current_path).to eq(edit_admin_form_path(form))
      expect(page).to have_content("Editing Form")
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


  xcontext "as Organization Manager" do
    let(:organization_manager) { FactoryBot.create(:user, :organization_manager, organization: organization) }

    before do
      login_as organization_manager
    end
  end


  context "without Form Manager permissions" do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:another_user) { FactoryBot.create(:user, organization: organization) }
    let!(:another_users_form) { FactoryBot.create(:form, :custom, organization: organization, user: another_user) }

    before do
      login_as(user)
      visit edit_admin_form_path(another_users_form)
    end

    it "does not see the Delete Question button" do
      expect(page).to_not have_link("Delete Question")
    end
  end

  context "as Touchpoints Manager" do
    let(:touchpoints_manager) { FactoryBot.create(:user, organization: organization) }

    before do
      login_as(touchpoints_manager)
    end

    describe "create a form" do
      before do
        visit new_admin_form_path
        fill_in "form_name", with: "New test form name"
        click_on "Create Form"
        visit admin_form_path(Form.first)
        click_on "Notification settings"
      end

      it "set notification_email to the email of the user who creates the form" do
        within ".usa-nav__secondary .user-name" do
          expect(page).to have_content(touchpoints_manager.email)
        end
        expect(find_field('form_notification_emails').value).to eq(touchpoints_manager.email)
      end
    end

    describe "copying a Form" do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: touchpoints_manager) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: touchpoints_manager) }

      before do
        visit admin_form_path(form)
        expect(page).to have_link("Copy form")
      end

      it "shows successful message" do
        click_on("Copy form")
        page.driver.browser.switch_to.alert.accept

        expect(expect(find_field('form_name').value).to eq "Copy of #{form.name}")
        expect(expect(find_field('form_title').value).to eq "Copy of #{form.name}")
        expect(expect(find_field('form_instructions').value).to eq form.instructions.to_s)
        expect(expect(find_field('form_disclaimer_text').value).to eq form.disclaimer_text.to_s)
        expect(expect(find_field('form_success_text').value).to eq form.success_text)

        expect(page).to have_content("Form was successfully copied.")
      end
    end

    describe "deleting Questions" do
      let(:form2) { FactoryBot.create(:form, :custom, organization: organization, user: touchpoints_manager) }
      let(:form_section2) { FactoryBot.create(:form_section, form: form2) }
      let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }

      context "with Form Manager permissions" do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, { form: form2, user: touchpoints_manager }) }

        before do
          visit edit_admin_form_path(form2)
        end

        it "see the delete button, click it, and delete the question" do
          expect(page).to have_link("Delete Question")

          click_on("Delete Question")
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content("Question was successfully destroyed.")
        end

        describe "update a Touchpoint Form Section" do
          let(:new_title) { "New Form Section Title" }

          before do
            visit edit_admin_form_form_section_path(form_section2.form, form_section2)
            fill_in("form_section[title]", with: new_title)
            click_button "Update Form section"
          end

          it "redirect to /admin/forms/:id/edit with a success flash message" do
            expect(page.current_path).to eq(edit_admin_form_path(form_section2.form))
            expect(page).to have_content("Form section was successfully updated.")
            expect(page).to have_content(new_title)
          end
        end
      end
    end

    describe "#export" do
      let(:form_manager) { FactoryBot.create(:user, organization: organization) }
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: form_manager)}
      let!(:radio_button_question) { FactoryBot.create(:question, :with_radio_buttons, form: form, form_section: form.form_sections.first) }
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
        expect(page).to have_content("Form is not yet deployable.")
      end
    end
  end
end
