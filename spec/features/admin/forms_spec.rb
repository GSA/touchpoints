require 'rails_helper'

feature "Forms", js: true do
  let(:future_date) {
    Time.now + 3.days
  }
  let!(:organization) { FactoryBot.create(:organization) }

  context "as Admin" do
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    before do
      login_as(admin)
    end

    describe "/admin/forms" do
      context "with 3 forms" do
        let!(:form) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form2) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:form3) { FactoryBot.create(:form, organization: organization, user: admin)}
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }
        let!(:user_role2) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form2) }
        let!(:user_role3) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form3) }

        before do
          visit admin_forms_path
        end

        it "display forms in a table" do
          rows = page.all("tr")
          expect(rows.length).to eq 4 # 3 forms, plus 1 header row
          expect(rows[1]).to have_content("1") # id
          expect(rows[1]).to have_link(form.name)
          expect(rows[1]).to have_content("0") # submissions
          expect(rows[1]).to have_link("Copy form")
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
      let(:new_form) { FactoryBot.build(:form, :custom, organization: organization) }

      describe "new touchpoint hosted form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in "form_name", with: new_form.name
          fill_in "form_title", with: new_form.title
          select(new_form.organization.name, from: "form_organization_id")
          find("label[for='form_delivery_method_touchpoints-hosted-only']").click
          find("label[for='form_display_header_square_logo']").click
          fill_in("form[omb_approval_number]", with: 1234)
          fill_in("form[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
          fill_in("form[notification_emails]", with: "admin@example.gov")
          click_on "Create Form"
        end

        it "redirect to /form/:uuid with a success flash message" do
          expect(page).to have_content("Form was successfully created.")
          @form = Form.last
          expect(page.current_path).to eq(admin_form_path(@form.short_uuid))
          expect(page).to have_content(new_form.name)
          expect(page).to have_content("1234")
          expect(page).to have_content("Notification emails")
          expect(page).to have_content("admin@example.gov")
        end
      end

      describe "new inline form" do
        before do
          visit new_admin_form_path
          expect(page.current_path).to eq(new_admin_form_path)
          fill_in "form_name", with: new_form.name
          fill_in "form_title", with: new_form.title
          select(new_form.organization.name, from: "form_organization_id")
          select("live", from: "form_aasm_state")
          find("label[for='form_delivery_method_inline']").click
          fill_in("form[notification_emails]", with: "admin@example.gov")
          click_on "Create Form"
        end

        it "redirect to /form/:uuid with a success flash message" do
          expect(page).to have_content("Form was successfully created.")
          @form = Form.last
          expect(page.current_path).to eq(admin_form_path(@form.short_uuid))
          expect(page).to have_content(new_form.name)
          expect(page).to have_content("admin@example.gov")
        end
      end

      describe "Form model validations" do
        describe "missing OMB Approval Number" do
          before "user tries to create a Touchpoint" do
            visit new_admin_form_path

            fill_in("form[name]", with: "Test Form")
            select(new_form.organization.name, from: "form_organization_id")
            find("label[for='form_delivery_method_touchpoints-hosted-only']").click
            fill_in("form[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
            click_button "Create Form"
          end

          it "display a flash message about missing OMB Approval Number" do
            within(".usa-alert--error") do
              expect(page).to have_content("Omb approval number required with an Expiration Date")
            end
          end
        end

        describe "missing Expiration Date" do
          before "user tries to create a Touchpoint" do
            visit new_admin_form_path

            fill_in("form[name]", with: "Test Form")
            select(new_form.organization.name, from: "form_organization_id")
            find("label[for='form_delivery_method_touchpoints-hosted-only']").click
            fill_in("form[omb_approval_number]", with: 1234)
            click_button "Create Form"
          end

          it "display a flash message about missing Expiration Date" do
            within(".usa-alert--error") do
              expect(page).to have_content("Expiration date required with an OMB Number")
            end
          end
        end
      end
    end

    describe "/admin/forms/:uuid" do
      let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin)}
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }

      before do
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
          let(:form2) { FactoryBot.create(:form, :open_ended_form, :inline, organization: organization, user: admin)}

          before "/admin/forms/:uiid/example" do
            visit example_admin_form_path(form2.short_uuid)
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

      describe "editing a Form definition" do
        before do
          visit edit_admin_form_path(form)
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

      describe "adding Questions" do
        describe "add a Text Field question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add a Question"
            expect(page.current_path).to eq(new_admin_form_question_path(form))
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
            within ".form-preview .question" do
              expect(page).to have_content("New Test Question")
              expect(page).to have_css("input[type='text']")
            end
          end
        end

        describe "add a Text Area question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add a Question"
            expect(page.current_path).to eq(new_admin_form_question_path(form))
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
            within ".question" do
              expect(page).to have_content("New Text Area")
              expect(page).to have_css("textarea")
            end
          end
        end

        describe "add a Radio Buttons question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add a Question"
            expect(page.current_path).to eq(new_admin_form_question_path(form))
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
            within ".form-preview .question" do
              expect(page).to have_content("New Test Question Radio Buttons")
              # Radio buttons won't be showing yet. Because they need to be added.
            end
          end
        end

        describe "add a Checkbox question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add a Question"
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

        describe "add a Dropdown question" do
          before do
            visit edit_admin_form_path(form)
            click_on "Add a Question"
            expect(page.current_path).to eq(new_admin_form_question_path(form))
            expect(page).to have_content("New Question")
            fill_in "dropdown", with: "New Test Question Radio Buttons"
            select("radio_buttons", from: "question_question_type")
            select("answer_01", from: "question_answer_field")

            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          xit "can add a Text Field Question" do
            expect(page).to have_content("Question was successfully created.")
            within ".question" do
              # expect(page).to have_content("New Test Question Radio Buttons")
              # Radio buttons won't be showing yet. Because they need to be added.
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
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form, form_section: form.form_sections.first) }

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
            click_on("Create Question option")
            expect(page).to have_content("Question option was successfully created.")
            within ".question .usa-checkbox" do
              expect(find("label")).to have_content("New Test Radio Option")
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
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form, form_section: form.form_sections.first) }
          let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

          before do
            visit edit_admin_form_path(form)
            within (".question") do
              click_on "Edit"
            end
          end

          it "click through to Edit page" do
            expect(page).to have_content("Editing Question Option")
          end
        end
      end

      describe "editing Question Options" do
        describe "edit Radio Button option" do
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form, form_section: form.form_sections.first) }
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
      visit edit_admin_form_path(form.short_uuid)
    end

    it "can edit form" do
      expect(page.current_path).to eq(edit_admin_form_path(form.short_uuid))
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
        visit edit_admin_form_path(form.short_uuid)
      end

      it "redirects to /admin" do
        expect(page.current_path).to eq(admin_root_path)
        expect(page).to have_content("no form with ID of #{form.short_uuid}")
      end
    end
  end


  xcontext "as Organization Manager" do
    let(:organization_manager) { FactoryBot.create(:user, :organization_manager, organization: organization) }

    before do
      login_as organization_manager
    end
  end


  context "without Touchpoint Manager permissions" do
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

    describe "copying a Form" do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: touchpoints_manager) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, form: form, user: touchpoints_manager) }

      before do
        visit admin_forms_path
      end

      it "displays Copy button" do
        row = all("table tr").last
        within(row) do
          expect(page).to have_link("Copy form")
        end
      end

      it "shows successful message" do
        row = all("table tr").last
        within(row) do
          click_on("Copy form")
        end

        page.driver.browser.switch_to.alert.accept
        # redirects to /admin/forms/:id/edit
        expect(page).to have_content("Form was successfully copied.")
      end
    end

    describe "deleting Questions" do
      let!(:form2) { FactoryBot.create(:form, :custom, organization: organization, user: touchpoints_manager) }
      let!(:form_section2) { FactoryBot.create(:form_section, form: form2) }
      let!(:question) { FactoryBot.create(:question, form: form2, form_section: form_section2) }

      context "with Touchpoint Manager permissions" do
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
            visit edit_admin_form_form_section_path(form_section2.form.id, form_section2.id)
            fill_in("form_section[title]", with: new_title)
            click_button "Update Form section"
          end

          it "redirect to /admin/forms/:id/edit with a success flash message" do
            expect(page.current_path).to eq(edit_admin_form_path(form_section2.form.id))
            expect(page).to have_content("Form section was successfully updated.")
            expect(page).to have_content(new_title)
          end
        end
      end
    end
  end
end
