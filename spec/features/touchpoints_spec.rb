require 'rails_helper'

feature "Touchpoints", js: true do
  context "as Admin" do
    let(:service) { FactoryBot.create(:service) }
    let(:touchpoint) { FactoryBot.create(:touchpoint, :with_form, service: service) }

    describe "/touchpoints" do
      before do
        visit touchpoint_path(touchpoint)
        expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
        expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
        expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
        fill_in("fba-text-body", with: "User feedback")
        click_button "Submit"
      end

      describe "display success message" do
        it "renders success flash message" do
          expect(page).to have_content("Thank you. Your feedback has been received.")
          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit") # stays on
        end
      end
    end

    describe "character_limit" do
      before do
        visit touchpoint_path(touchpoint)
        expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
        expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
        expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
        fill_in("fba-text-body", with: "T" * 100 * ((touchpoint.form.character_limit.to_i / 100) + 10))
        click_button "Submit"
      end

      describe "display flash error on submission" do
        it "renders body character_limit flash message" do
          expect(page).to have_content("body is limited to #{touchpoint.form.character_limit} characters")
          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
        end
      end
    end

    describe "/touchpoints?location_code=" do
      before do
        visit submit_touchpoint_path(touchpoint, location_code: "TEST_LOCATION_CODE")
        fill_in("fba-text-body", with: "User feedback")
        click_button "Submit"
      end

      describe "#show" do
        it "renders success flash message and persists location_code" do
          expect(page).to have_content("Thank you. Your feedback has been received.")
          expect(page).to have_current_path("/touchpoints/#{touchpoint.id}/submit?location_code=TEST_LOCATION_CODE") # stays on same page after form submission

          # Asserting against the database/model directly here isn't ideal.
          # An alternative is to send location_code back to the client and assert against it
          expect(Submission.last.location_code).to eq "TEST_LOCATION_CODE"
        end
      end
    end
  end
end
