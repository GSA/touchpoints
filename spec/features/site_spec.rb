require 'rails_helper'

feature "general site navigation", js: true do
  context "as Admin" do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, :admin, organization: organization) }

    before do
      login_as(user)
      visit root_path
    end

    context "logged in" do
      describe "/admin/services" do
        before do
          click_on "Services"
        end

        it 'renders successfully' do
          expect(page.current_path).to eq(admin_services_path)
          expect(page).to have_content("Services")
          expect(page).to have_content("New Service")
        end
      end

      describe "/admin/websites" do
        before do
          click_on "Websites"
        end

        it 'renders successfully' do
          expect(page.current_path).to eq(admin_websites_path)
          expect(page).to have_content("Websites")
          expect(page).to have_content("New Website")
          expect(page).to have_content("All websites are viewable by Touchpoints users.")
        end
      end

      describe "/admin/collections" do
        before do
          click_on "Collections"
        end

        it 'renders successfully' do
          expect(page.current_path).to eq(admin_collections_path)
          expect(page).to have_content("Data Collections")
          expect(page).to have_content("New Data Collection")
        end
      end
    end

  end
end
