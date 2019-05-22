require 'rails_helper'

feature "Managing Organizations", js: true do
  let(:new_organization) { FactoryBot.build(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }

  context "as Admin" do
    before "visit Organization listing" do
      login_as admin
      visit admin_organizations_path
    end

    it "display Admin-specific UI content" do
      expect(page).to have_link(Organization.first.name)
      expect(page).to have_link("New Organization")
    end

    describe "create an Organization" do
      before do
        click_on "New Organization"

        fill_in :organization_name, with: new_organization.name
        fill_in :organization_domain, with: new_organization.domain
        fill_in :organization_url, with: new_organization.url
        fill_in :organization_abbreviation, with: new_organization.abbreviation
        fill_in :organization_notes, with: new_organization.notes

        click_on "Create Organization"
      end

      it "successfully creates an Organization" do
        expect(page).to have_content("Organization was successfully created.")
      end
    end
  end

  context "as Organization Manager" do
    before "Sign in" do
      login_as organization_manager
      visit admin_organizations_path
    end

    it "redirected do homepage with error message" do
      expect(page.current_path).to eq(root_path)
      expect(page).to have_content("Authorization is Required")
    end
  end
end
