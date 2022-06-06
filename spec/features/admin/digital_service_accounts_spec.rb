require 'rails_helper'

feature "Digital Service Accounts", js: true do
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

    describe 'create' do
      before 'fill-in the form' do
        visit admin_digital_service_accounts_path
        click_on 'New Account'
        expect(page).to have_content('New Social Media Account')
        fill_in :digital_service_account_name, with: 'Test Name'
        select(organization.name, from: 'digital_service_account[organization_id]')
        select('Facebook', from: 'digital_service_account[account]')
        click_on 'Create Digital service account'
      end

      it 'creates Digital Service Account successfully' do
        expect(page).to have_content('Digital service account was successfully created')
        expect(page).to have_content('Event log')
        within('.events') do
          expect(page).to have_content('digital_service_account_created by admin@example.gov')
        end
      end

    end

    describe 'add tag' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)

        fill_in("digital_service_account_tag_list", with: "tag123")
        find(".organizations").click # just to lose focus
      end

      it 'creates a tag' do
        expect(page).to have_css(".usa-tag", text: "tag123".upcase)
      end
    end

    describe 'remove tag' do
      let(:tag_text) { "a brand new tag" }
      let(:digital_service_account) { FactoryBot.create(:digital_service_account, tag_list: [tag_text]) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)

        find(".tag-list .remove-tag-link").click

      end

      it 'removes the tag' do
        expect(page).to_not have_content(tag_text)
      end
    end

  end
end
