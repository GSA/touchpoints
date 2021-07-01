require 'rails_helper'

feature "Managing Websites", js: true do
  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:test_website) { FactoryBot.build(:website) }

  context "as Admin" do
    before "visit Organization listing" do
      login_as admin
      visit admin_websites_path
    end

    it "load the Websites#index page" do
      expect(page).to have_content("Websites")
      expect(page).to have_content("Website inventory is an experimental feature.")
      expect(page).to have_content("New Website")
    end

    describe "create a new Website" do
      before "user fill-in the form" do
        click_on "New Website"
        expect(page).to have_content("New Website")
        fill_in :website_domain, with: test_website.domain
        select("Application", from: "website_type_of_site")
        click_on "Create Website"
      end

      it "create Website successfully" do
        expect(page).to have_content("Website was successfully created.")
        expect(page).to have_content(test_website.domain)
      end
    end
  end
end
