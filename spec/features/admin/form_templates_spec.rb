require 'rails_helper'

feature "Managing Form Templates", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:non_admin) { FactoryBot.create(:user, :organization_manager) }
  let!(:form_template) { FactoryBot.create(:form_template) }

  context "as Admin" do
    before do
      login_as admin
    end

    describe "new Form Template" do
      before "user creates a Form Template" do
        visit admin_form_templates_path
      end

      describe "create new Form Template" do
        before do
          click_link "New Form Template"
        end

        it "arrive at Form" do
          expect(page).to have_content("New Form Template")
        end
      end
    end

    describe "edit existing Form Template" do
      before do
        visit admin_form_template_path(FormTemplate.first)
      end

      it "edit Form Template" do
        click_link "Edit"
        expect(page).to have_content("Editing Form Template")
        fill_in("form_template_name", with: "Updated Form Name")
        click_button "Update Form template"
        expect(page).to have_content("Form template was successfully updated.")
        expect(page).to have_content("Name: Updated Form Name")
      end
    end

    describe "view existing Form Templates" do
      before do
        @a11 = FactoryBot.create(:form_template, :a11)
        visit admin_form_templates_path
      end

      describe "display Edit link" do
        it "display Edit link" do
          expect(page).to have_link("Edit")
        end
      end

      it "loads each of the forms" do
        visit admin_form_template_path(FormTemplate.first)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{FormTemplate.first.name}")

        visit admin_form_template_path(@a11)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{@a11.name}")
      end
    end
  end

  context "for non-Admins" do
    before do
      login_as non_admin
      visit admin_form_templates_path
    end

    describe "do not display Edit link" do
      it "do not display Edit link" do
        expect(page).to_not have_content("Edit")
      end
    end
  end

end
