require 'rails_helper'

feature "Digital Products", js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization: organization) }
  let!(:service) { FactoryBot.create(:service, organization: organization, service_provider: service_provider, service_owner_id: admin.id) }

  let!(:digital_product) { FactoryBot.create(:digital_product) }
  let!(:digital_product_2) { FactoryBot.create(:digital_product) }

  context "as Admin" do
    before do
      login_as admin
    end

    describe "#index" do
      before do
        visit admin_digital_products_path
      end

      it "load the DigitalProducts#index page" do
        expect(page).to have_content("Digital Products")
        expect(page).to have_link("New Digital Product")
        expect(page.current_path).to eq(admin_digital_products_path)
        expect(page).to have_css("tbody tr", count: 2)
      end
    end
  end
end
