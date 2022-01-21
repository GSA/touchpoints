require 'rails_helper'

RSpec.describe "Personas", js: true do

  let!(:new_organization) { FactoryBot.build(:organization, name: "New Org") }

  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  context "as Admin" do
    before "visit Organization listing" do
      login_as admin
      visit admin_personas_path
    end

    it "display page content" do
      expect(page).to have_content("Personas")
      expect(page).to have_link("New Persona")
    end
  end

end
