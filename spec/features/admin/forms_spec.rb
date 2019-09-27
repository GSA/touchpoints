require 'rails_helper'

feature "Forms", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let!(:organization) { FactoryBot.create(:organization) }

  context "as Admin" do
    before do
      login_as(admin)
    end

    describe "access New Form Page" do
      before do
        visit admin_forms_path
      end

      it "click through to New Form Page" do
        expect(page.current_path).to eq(admin_forms_path)
        click_on "New Form"
        expect(page.current_path).to eq(new_admin_form_path)
      end
    end

    describe "New Form page" do
      let(:new_form) { FactoryBot.build(:form, :custom) }

      before do
        visit new_admin_form_path
      end

      it "can create New Custom Form" do
        expect(page.current_path).to eq(new_admin_form_path)
        fill_in "form_name", with: new_form.name
        fill_in "form_title", with: new_form.title
        fill_in "form_kind", with: new_form.kind
        click_on "Create Form"
        expect(page).to have_content("Form was successfully created.")
        expect(page.current_path).to eq(admin_form_path(Form.first))
      end
    end

    context "Edit Form page" do
      let(:form) { FactoryBot.create(:form, :custom) }

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

            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "can add a Text Field Question" do
            expect(page).to have_content("Question was successfully created.")
            within ".question" do
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

            expect(find_field('question_position').value).to eq '1'
            click_on "Create Question"
          end

          it "can add a Text Field Question" do
            expect(page).to have_content("Question was successfully created.")
            within ".question" do
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
            within ".question" do
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
        let(:service) { FactoryBot.create(:service) }
        let(:touchpoint) { FactoryBot.create(:touchpoint, service: service) }

        let(:form) { FactoryBot.create(:form, :custom, touchpoint: touchpoint) }
        let!(:question) { FactoryBot.create(:question, form: form) }

        context "without Service Manager permissions" do
          before do
            visit edit_admin_form_path(form)
          end

          it "does not see the Delete Question button" do
            expect(page).to_not have_link("Delete Question")
          end
        end

        context "with Service Manager permissions" do
          let!(:user_service) { FactoryBot.create(:user_service, :service_manager, { service: service, user: admin }) }

          before do
            visit edit_admin_form_path(form)
          end

          it "see the delete button, click it, and delete the question" do
            expect(page).to have_link("Delete Question")

            click_on("Delete Question")
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content("Question was successfully destroyed.")
          end
        end

      end

      describe "adding Question Options" do
        describe "add Radio Button options" do
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form) }

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
            within ".question" do
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
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form) }
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
          let!(:radio_button_question) { FactoryBot.create(:question, :radio_buttons, form: form) }
          let!(:radio_button_option) { FactoryBot.create(:question_option, question: radio_button_question, position: 1) }

          before do
            visit edit_admin_form_question_question_option_path(form, radio_button_question, radio_button_option)
            fill_in "question_option_text", with: "Edited Question Option Text"
            click_on "Update Question option"
          end

          it "click through to Edit page" do
            expect(page).to have_content("Question option was successfully updated.")
            within (".question") do
              expect(page).to have_content("Edited Question Option Text")
            end
          end
        end
      end

    end

  end
end
