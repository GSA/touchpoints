require 'rails_helper'

feature "Example Website Integration", js: true do

  describe "Admin" do
    let(:admin) { FactoryBot.create(:user, :admin) }

    before do
      login_as(admin)
      visit admin_root_path
    end

    it "has admin links" do
      expect(page).to have_link("Manage Organizations")
      expect(page).to have_link("Manage Form Templates")
    end
  end

  describe "Organization Manager" do
    let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }

    before do
      login_as(organization_manager)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Get Started by creating a Service.")
      expect(page).to have_content("Then, create a Touchpoint for that Service.")
      expect(page).to have_content("Then, update the Touchpoint's Form.")
    end
  end

  describe "Service Manager" do
    let(:service_manager) { FactoryBot.create(:user) }
    let(:service) { FactoryBot.create(:service) }
    let!(:user_service) { FactoryBot.create(:user_service, :service_manager, user: service_manager, service: service) }

    before do
      login_as(service_manager)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Get Started by creating a Service.")
      expect(page).to have_content("Then, create a Touchpoint for that Service.")
      expect(page).to have_content("Then, update the Touchpoint's Form.")
    end
  end

  # Note:
  # Public users do not log in.
  # Logged in users are .gov users, but may not have permissions
  #  to edit any Services or other resources
  describe "non-privileged User" do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as(user)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Get Started by creating a Service.")
      expect(page).to have_content("Then, create a Touchpoint for that Service.")
      expect(page).to have_content("Then, update the Touchpoint's Form.")
    end
  end

  describe "non logged-in User" do
    before do
      visit admin_root_path
    end

    it "redirected to home page and sees flash message" do
      expect(page.current_path).to eq(root_path)
      expect(page).to have_content("Authorization is Required")
    end
  end
end
