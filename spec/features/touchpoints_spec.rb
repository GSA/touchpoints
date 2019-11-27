require 'rails_helper'

feature "Touchpoints", js: true do
  context "as Admin" do
    let(:service) { FactoryBot.create(:service) }
    let(:touchpoint) { FactoryBot.create(:touchpoint, :with_form, service: service) }

    describe "/touchpoints" do
      context "default success text" do
        before do
          visit touchpoint_path(touchpoint)
          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
          expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
          expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
          fill_in("answer_01", with: "User feedback")
          click_button "Submit"
        end

        describe "display default success text" do
          it "renders success flash message" do
            expect(page).to have_content("Thank you. Your feedback has been received.")
            expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit") # stays on
          end
        end
      end

      context "custom success text" do
        before do
          touchpoint.form.update_attribute(:success_text, "Much success, yessss.")
          touchpoint.reload
          visit touchpoint_path(touchpoint)
          expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
          expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
          expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
          fill_in("answer_01", with: "User feedback")
          click_button "Submit"
        end

        describe "display custom success text" do
          it "renders success flash message" do
            expect(page).to have_content(touchpoint.form.success_text)
            expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit") # stays on
          end
        end
      end
    end

    describe "required question" do
      before do
        touchpoint.form.questions.first.update_attribute(:is_required, true)
        visit touchpoint_path(touchpoint)
        click_on "Submit"
      end

      it "displays an error message" do
        expect(page).to have_content("You must respond to question: 1. Test Open Area")
      end

      it "can successfully submit after completing the required question" do
        fill_in("answer_01", with: "a response to this required question")
        click_button "Submit"
        expect(page).to have_content("Thank you. Your feedback has been received.")
      end
    end

    describe "character_limit" do
      before do
        question = touchpoint.form.questions.first
        question.update_attribute(:character_limit, 150)
        visit touchpoint_path(touchpoint)
        expect(page.current_path).to eq("/touchpoints/#{touchpoint.id}/submit")
        expect(page).to have_content("OMB Approval ##{touchpoint.omb_approval_number}")
        expect(page).to have_content("Exp. Date #{touchpoint.expiration_date.strftime("%m/%d/%Y")}")
        fill_in("answer_01", with: "T" * 145)
      end

      describe "character counter" do
        it "updates character count" do
          expect(page).to have_content("Chars remaining: 5")
        end
      end
    end

    describe "/touchpoints?location_code=" do
      before do
        visit submit_touchpoint_path(touchpoint, location_code: "TEST_LOCATION_CODE")
        fill_in("answer_01", with: "User feedback")
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
