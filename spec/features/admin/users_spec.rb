require 'rails_helper'

feature "Managing Users", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }

  context "as Admin" do
    before "user creates a Touchpoint" do
      login_as admin
      visit admin_users_path
    end

    it "display list of Users" do
      expect(page).to have_content("Users")
      within("table") do
        expect(page).to have_content("Organization Name")
        expect(page).to have_content("Edit")
      end
    end

    it "click through to User#edit" do
      page.all("tr")[1].click_on("Edit")
      expect(page).to have_content("Editing a User")
    end

    describe "edit a User" do
      before do
        visit edit_admin_user_path(organization_manager)
        expect(page.find("input[name='user[admin]'][type='hidden']", visible: false).value).to eq("0")
        page.find("label[for='user_admin']").click
        click_button("Update User")
      end

      it "update existing user to an Admin role" do
        expect(page.find(".usa-label")).to have_content("Admin User".upcase)
      end
    end
  end
end
