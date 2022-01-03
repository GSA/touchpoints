require 'rails_helper'

feature "Managing Services", js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization ) }
  let!(:service) { FactoryBot.create(:service, organization: organization, service_provider: service_provider ) }
  let!(:service2) { FactoryBot.create(:service, organization: organization, service_provider: service_provider) }

  before do
    service2.tag_list.add("feature-request")
    service2.tag_list.add("policy")
    service2.save
  end

  context "as Admin" do
    before do
      login_as admin
      visit admin_services_path
    end

    it "load the Services#index page" do
      expect(page).to have_content("Managing Services in Touchpoints")
      expect(page.current_path).to eq(admin_services_path)
      expect(page).to have_link("New Service")
      expect(page).to have_css("tbody tr", count: 2)
    end

    describe "create a new Service" do
      before "fill-in the form" do
        click_on "New Service"
        expect(page).to have_content("New Service")
        select(service_provider.name, from: "service[service_provider_id]")
        fill_in :service_name, with: "New Service Name"
        click_on "Create Service"
      end

      it "create Website successfully" do
        expect(page).to have_content("Service was successfully created")
        expect(page).to have_content("New Service Name")
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
        find(".usa-tag", text: "FEATURE-REQUEST").click # to create the tag
      end

      it "newly created tag is displayed on the page" do
        expect(page.current_url).to include("tag=feature-request")
        expect(page).to have_css("tbody tr", count: 1)
      end
    end

  end
end
