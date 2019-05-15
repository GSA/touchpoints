require 'rails_helper'

feature "Managing Form Templates", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:non_admin) { FactoryBot.create(:user, :organization_manager) }
  let!(:form_template) { FactoryBot.create(:form_template) }

  context "as Admin" do
    before "user creates a Touchpoint" do
      login_as admin
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

    describe "edit existing Form Template" do

    end

    describe "display Edit link" do
      it "display Edit link" do
        expect(page).to have_link("Edit")
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
