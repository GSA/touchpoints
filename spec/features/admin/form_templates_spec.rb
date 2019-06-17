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

    end

    describe "display Edit link" do
      it "display Edit link" do
        expect(page).to have_link("Edit")
      end
    end

    describe "viewing each Form Template" do
      before do
        @a11 = FactoryBot.create(:form_template, :a11)
        @recruiter = FactoryBot.create(:form_template, :recruiter)
        @oewci = FactoryBot.create(:form_template, :open_ended_with_contact_info)
        visit admin_form_templates_path
      end

      it "loads each of the forms" do
        visit admin_form_template_path(FormTemplate.first)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{FormTemplate.first.name}")

        visit admin_form_template_path(@a11)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{@a11.name}")

        visit admin_form_template_path(@recruiter)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{@recruiter.name}")

        visit admin_form_template_path(@oewci)
        expect(page).to have_content("Viewing a Form Template")
        expect(page).to have_content("Name: #{@oewci.name}")
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
