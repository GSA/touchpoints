require 'rails_helper'

feature "Managing Users", js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  context "as Admin" do
    before "user creates a Touchpoint" do
      login_as admin
      visit admin_users_path
    end

    it "display list of Users" do
      expect(page).to have_content("Users")
      within("table") do
        expect(page).to have_content("Organization Name")
      end
    end

    it "click through to User#edit" do
      within("table") do
        click_link admin.email
      end
      expect(page).to have_content("Viewing User")
      expect(page.current_path).to eq(admin_user_path(admin))

      click_on("Edit user")
      expect(page).to have_content("Editing User")
    end

    it "display Last signed in" do
      within("table") do
        expect(page).to have_content("Last signed in")
      end
    end

    describe "view a User" do
      before do
        visit admin_user_path(user)
      end

      it "shows no forms message" do
        expect(page).to have_content("No Forms at this time")
      end

      context "with submissions" do
        let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user) }
        let!(:user_role) { FactoryBot.create(:user_role, user: user, form:form, role: UserRole::Role::FormManager) }

        before do
          visit admin_user_path(user)
        end

        it "shows each form" do
          expect(page).to have_link(form.name)
        end
      end

      describe "/admin/users/inactive" do
        before do
          visit inactive_admin_users_path
        end

        it "displays inactive users" do
          expect(page).to have_css("table")
          expect(User.count).to eq(2) # out of 2
          expect(page).to have_content(user.email) # only 1 is inactive
        end
      end
    end

    describe "edit a User" do
      let!(:another_organization) { FactoryBot.create(:organization, :another) }

      before do
        visit edit_admin_user_path(user)
      end

      it "update existing user to another Organization" do
        expect(page.find("select[name='user[organization_id]']").value).to eq("1")
        select(another_organization.name, from: "user_organization_id")
        click_button("Update User")
        expect(page).to have_content("User was successfully updated.")
        expect(page).to have_content(another_organization.name)
      end

      it "update existing user to an Admin role" do
        expect(page.find("input[name='user[admin]'][type='hidden']", visible: false).value).to eq("0")
        page.find("label[for='user_admin']").click
        click_button("Update User")
        expect(page.find(".usa-tag")).to have_content("Admin User".upcase)
      end
    end
  end

  context "as non-Admin" do
    let(:user) { FactoryBot.create(:user, organization: organization) }

    before do
      login_as user
      visit admin_users_path
    end

    it "is not permitted" do
      expect(page).to have_content("Authorization is Required")
    end

    describe "/admin/users/inactive" do
      before do
        visit inactive_admin_users_path
      end

      it "is not permitted to see inactive users list" do
        expect(page).to have_content("Authorization is Required")
      end
    end
  end

end
