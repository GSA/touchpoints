require 'rails_helper'

feature "Managing Services", js: true do
  let(:user) { FactoryBot.create(:user) }

  before "user creates a Touchpoint" do
    login_as user
    visit admin_services_path
  end

  it "arrives at /admin/services" do
    expect(page.current_path).to eq("/admin/services")
  end

  context "logged in as Webmaster" do
    before "user creates a Touchpoint" do
      click_link "New Service"
    end

    it "arrives at /admin/services/new" do
      expect(page.current_path).to eq("/admin/services/new")
    end

    describe "#index" do
      before do
        fill_in "service_name", with: "Test Public Service"
        fill_in "service_description", with: "Test service description"
        click_button "Create Service"
      end

      it "creates Service successfully" do
        expect(page).to have_content("Service was successfully created.")
        expect(page).to have_content("Test Public Service")
      end
    end
  end
end
