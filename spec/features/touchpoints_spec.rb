require 'rails_helper'

feature "Touchpoints", js: true do
  describe "/touchpoints" do
    describe "#index" do
      let(:user) { FactoryBot.create(:user) }
      let!(:organization) { FactoryBot.create(:organization) }

      before "user completes Sign Up form" do
        login_as user
        visit new_touchpoint_path
        fill_in("touchpoint[name]", with: "Test Touchpoint")
        select(organization.name, from: "touchpoint[organization_id]")
        fill_in("touchpoint[purpose]", with: "Compliance")
        fill_in("touchpoint[meaningful_response_size]", with: 50)
        fill_in("touchpoint[behavior_change]", with: "to be determined")
        fill_in("touchpoint[notification_emails]", with: "admin@example.com")
        click_button "Create Touchpoint"
      end

      it "redirect to /touchpoints/:id with a success flash message" do
        expect(page.current_path).to eq(touchpoint_path(Touchpoint.first.id))
        expect(page).to have_content("Touchpoint was successfully created.")

        expect(page).to have_content("Notification emails: admin@example.com")
      end
    end
  end
end
