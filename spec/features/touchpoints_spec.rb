require 'rails_helper'

feature "Touchpoints", js: true do
  context "as Admin" do
    describe "/touchpoints" do
      let(:user) { FactoryBot.create(:user) }

      before do
        login_as user
      end

      describe "#show" do
        let!(:organization) { FactoryBot.create(:organization) }
        let(:touchpoint) { FactoryBot.create(:touchpoint) }

        before "user completes Sign Up form" do
          visit touchpoint_path(touchpoint)

          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
          expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
          expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
          fill_in("fba-text-body", with: "User feedback")
          click_button "Submit"
        end

        it "redirect to /confirmation with a flash message" do
          expect(page).to have_content("Thank you. Your feedback has been received.")
          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit") # stays on same page after form submission
        end
      end
    end
  end
end
