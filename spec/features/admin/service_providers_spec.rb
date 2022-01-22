require 'rails_helper'

feature "Service Provider", js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization ) }
  let!(:service) { FactoryBot.create(:service, organization: organization, service_provider: service_provider, service_owner_id: user.id) }

  context "as Admin" do
    before do
      login_as admin
      visit admin_service_providers_path
    end

    it "load the ServiceProviders#index page" do
      expect(page).to have_content("Service Providers")
      expect(page.current_path).to eq(admin_service_providers_path)
      expect(page).to have_content(service_provider.name)
      expect(page).to have_content("Download as hisps.csv")
    end
  end

end
