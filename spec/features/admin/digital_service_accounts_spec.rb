require 'rails_helper'

feature "Digital Services", js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization ) }
  let!(:service) { FactoryBot.create(:service, organization: organization, service_provider: service_provider, service_owner_id: user.id) }
  let!(:service2) { FactoryBot.create(:service, organization: organization, service_provider: service_provider, service_owner_id: admin.id) }

  # before do
  #   service2.tag_list.add("feature-request")
  #   service2.tag_list.add("policy")
  #   service2.save
  # end

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

        it "load the Services#index page" do
          expect(page).to have_content("Digital Service Account")
        end

      end
    end

    describe "add a tag to a Service" do
      before "add the tag" do
        visit admin_service_path(service2)
        fill_in "service_tag_list", with: "new-tag"
        find("body").click # to create the tag
      end

      it "newly created tag is displayed on the page" do
        expect(page).to have_css(".usa-tag", text: "NEW-TAG")
      end
    end

    describe "search by Tag" do
      before do
        visit admin_services_path
        find(".usa-tag", text: "FEATURE-REQUEST").click # to create the tag
      end

      it "newly created tag is displayed on the page" do
        expect(page.current_url).to include("tag=feature-request")
        expect(page).to have_css("tbody tr", count: 1)
      end
    end

    describe "Service Managers" do
      before do
        visit edit_admin_service_path(service)
        select(admin.email, from: "service_manager_id")
      end

      it "display new service manager's email as a tag" do
        expect(page).to have_css(".usa-tag", text: admin.email.upcase)
      end
    end

  end
end
