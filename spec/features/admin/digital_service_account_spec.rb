require 'rails_helper'

feature "Managing Services", js: true do
  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  context "as Admin" do
    before do
      login_as admin
    end

    describe "#index" do
      it "load the Services#index page" do
        visit admin_digital_service_accounts_path
        expect(page).to have_content("Social Media Accounts")
        expect(page.current_path).to eq(admin_digital_service_accounts_path)
        expect(page).to have_link("New Account")
      end
    end

    describe "create and update" do
      before "fill-in the form" do
        visit admin_digital_service_accounts_path
        click_on "New Account"
        expect(page).to have_content("New Social Media Account")
        fill_in :digital_service_account_name, with: "Test Name"
        select(organization.name, from: "digital_service_account[organization_id]")
        select("Facebook", from: "digital_service_account[account]")
        click_on "Create Digital service account"
      end

      it "creates Digital Service Account successfully" do
        expect(page).to have_content("Digital service account was successfully created")
        expect(page).to have_content("Recent Changes")
        within(".recent-changes") do
          expect(page).to have_content("created by")
        end
      end

      it "updates Digital Service Account successfully" do
        click_on "Edit"
        fill_in :digital_service_account_short_description, with: "New description"
        click_on "Update Digital service account"
        expect(page).to have_content("Digital service account was successfully updated")
        expect(page).to have_content("Recent Changes")
        within(".recent-changes") do
          expect(page).to have_content("created by")
          expect(page).to have_content("updated by")
        end
      end
    end
  end
end
