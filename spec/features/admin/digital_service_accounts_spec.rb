require 'rails_helper'

feature "Digital Services", js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }


  context "as Admin" do
    before do
      login_as admin
    end

    context "with no records" do
      describe "#index" do
        before do
          visit admin_digital_service_accounts_path
        end

        it "load the Services#index page" do
          expect(page).to have_content("Social Media Accounts")

          expect(page).to have_link("Back to Digital Registry")
          expect(page).to have_link("New Account")
          expect(page).to have_link("Export results to .csv")

          within(".usa-table") do
            expect(page).to have_content("Organization")
            expect(page).to have_content("Platform")
            expect(page).to have_content("Account name")
            expect(page).to have_content("Status")
            expect(page).to have_content("User")
            expect(page).to have_content("Updated at")
          end
        end
      end
    end

    context "with records" do
      let!(:organizations) { FactoryBot.create_list(:organization, 7) }
      let(:users) { FactoryBot.create_list(:user, 5, organization: organizations.sample) }
      let!(:digital_service_accounts) { FactoryBot.create_list(:digital_service_account, 10, organization: organizations.sample, user: users.sample) }

      describe "#index" do
        before do
          visit admin_digital_service_accounts_path
          within(".usa-table tbody tr:first-child") do
            click_on("Service Account 1")
          end
        end

        it "load the DigitalServiceAccount#index page" do
          expect(page).to have_content("Social Media Account")
          expect(page).to have_content("Service Account 1")
        end

      end
    end
  end
end
