require 'rails_helper'

feature "Managing Users", js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:organization_manager) { FactoryBot.create(:user, :organization_manager, organization: organization) }

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
      expect(page).to have_content("Editing User")
    end

    describe "view a User" do
      before do
        visit admin_user_path(organization_manager)
      end

      it "shows no forms message" do
        expect(page).to have_content("No Forms at this time")
      end

      context "with submissions" do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: organization_manager) }
        let!(:user_role) { FactoryBot.create(:user_role, user: organization_manager, form:form, role: UserRole::Role::FormManager) }

        before do
          visit admin_user_path(organization_manager)
        end

        it "shows each form" do
          expect(page).to have_link(form.name)
        end
      end
    end

    describe "edit a User" do
      before do
        visit edit_admin_user_path(organization_manager)
        expect(page.find("input[name='user[admin]'][type='hidden']", visible: false).value).to eq("0")
        page.find("label[for='user_admin']").click
        click_button("Update User")
      end

      it "update existing user to an Admin role" do
        expect(page.find(".usa-tag")).to have_content("Admin User".upcase)
      end
    end
  end
end
