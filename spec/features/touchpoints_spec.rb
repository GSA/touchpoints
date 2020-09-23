require 'rails_helper'

feature "Touchpoints", js: true do
  context "as Admin" do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user) }

    describe "/touchpoints" do
      context "default success text" do
        before do
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime("%m/%d/%Y")}")
          fill_in("answer_01", with: "User feedback")
          click_button "Submit"
        end

        describe "display default success text" do
          it "renders success flash message" do
            expect(page).to have_content("Thank you. Your feedback has been received.")
            expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on
          end
        end
      end

      context "custom success text" do
        before do
          form.update_attribute(:success_text, "Much success. \n With a second line.")
          form.reload
          visit touchpoint_path(form)
          expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
          expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
          expect(page).to have_content("Expiration Date #{form.expiration_date.strftime("%m/%d/%Y")}")
          fill_in("answer_01", with: "User feedback")
          click_button "Submit"
        end

        describe "display custom success text" do
          it "renders success flash message" do
            expect(page).to have_text(form.success_text.gsub("\n ", "")) # convert the line break and following space to html text
            expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit") # stays on same page
          end
        end
      end
    end

    describe "checkbox question" do
      let!(:checkbox_form) { FactoryBot.create(:form, :checkbox_form, organization: organization, user: user) }

      before do
        visit touchpoint_path(checkbox_form)
        all('.usa-checkbox__label').each do |checkbox_label|
          checkbox_label.click
        end
        click_on "Submit"
      end

      it "persists checkbox question values to db as comma separated list" do
        expect(page).to have_content("Thank you. Your feedback has been received.")
        expect(Submission.last.answer_03).to eq "One,Two,Three,Four"
      end

    end

    describe "required question" do
      before do
        form.questions.first.update_attribute(:is_required, true)
        visit touchpoint_path(form)
        click_on "Submit"
      end

      it "displays an error message" do
        expect(page).to have_content("You must respond to question: 1. Test Open Area")
      end

      it "regression: does not display invisible error message inputs" do
        expect(page).to have_no_css("input", visible: true)
      end

      it "can successfully submit after completing the required question" do
        fill_in("answer_01", with: "a response to this required question")
        click_button "Submit"
        expect(page).to have_content("Thank you. Your feedback has been received.")
      end
    end

    describe "character_limit" do
      before do
        question = form.questions.first
        question.update_attribute(:character_limit, 150)
        visit touchpoint_path(form)
        expect(page.current_path).to eq("/touchpoints/#{form.short_uuid}/submit")
        expect(page).to have_content("OMB Approval ##{form.omb_approval_number}")
        expect(page).to have_content("Expiration Date #{form.expiration_date.strftime("%m/%d/%Y")}")
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
        visit submit_touchpoint_path(form, location_code: "TEST_LOCATION_CODE")
        fill_in("answer_01", with: "User feedback")
        click_button "Submit"
      end

      describe "#show" do
        it "renders success flash message and persists location_code" do
          expect(page).to have_content("Thank you. Your feedback has been received.")
          expect(page).to have_current_path("/touchpoints/#{form.short_uuid}/submit?location_code=TEST_LOCATION_CODE") # stays on same page after form submission

          # Asserting against the database/model directly here isn't ideal.
          # An alternative is to send location_code back to the client and assert against it
          expect(Submission.last.location_code).to eq "TEST_LOCATION_CODE"
        end
      end
    end

    describe "A-11 Version 2 Form" do
      let!(:custom_form) { FactoryBot.create(:form, :a11_v2, organization: organization, user: user) }

      before do
        visit submit_touchpoint_path(custom_form)
        find("label[for='star4']").click
        # fill_in("answer_02", with: "User feedback")
        fill_in("answer_03", with: "User feedback")
        click_button "Submit"
      end

      it "" do
        expect(page).to have_content("Thank you. Your feedback has been received.")

        # Asserting against the database/model directly here isn't ideal.
        # An alternative is to send location_code back to the client and assert against it
        last_submission = Submission.last
        expect(last_submission.answer_01).to eq "4"
        # expect(last_submission.answer_02).to eq "TEST_LOCATION_CODE"
        expect(last_submission.answer_03).to eq "User feedback"
      end
    end
  end
end
