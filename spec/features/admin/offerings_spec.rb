require 'rails_helper'

feature "Offerings", js: true do
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  context "as Admin" do
    before do
      login_as admin
    end

    describe "#index" do
      before do
        visit admin_offerings_path
      end

      it "load the Offerings#index page" do
        expect(page).to have_content("Offerings")
        expect(page).to have_link("New Offering")
        expect(page.current_path).to eq(admin_offerings_path)
      end
    end
  end
end
