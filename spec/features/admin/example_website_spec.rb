require 'rails_helper'

feature "Example Website Integration", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:open_ended_form) { FactoryBot.create(:form, :open_ended_form) }
  let(:open_ended_touchpoint) { FactoryBot.create(:touchpoint, form: open_ended_form) }
  let(:recruiter_form) { FactoryBot.create(:form, :recruiter) }
  let!(:recruiter_touchpoint) { FactoryBot.create(:touchpoint, form: recruiter_form) }

  describe "third-party .gov website" do
    before do
      login_as(admin)
    end

    context "Open-ended Touchpoint" do
      before do
        visit example_admin_touchpoint_path(open_ended_touchpoint)
      end

      it "loads Badge with Text" do
        expect(page).to have_content("Help improve this site")
      end

      describe "clicking the Feedback Form tab" do
        before do
          click_on "fba-button"
        end

        it "opens Modal" do
          expect(page).to have_css("#fba-modal-dialog", visible: true)
          within "#fba-modal-dialog" do
            expect(page).to have_content open_ended_touchpoint.form.title
          end
        end

        describe "submit the form" do
          before "fill-in the form" do
            fill_in "answer_01", with: "All my open-ended concerns."
            click_button "Submit"
          end

          it "display .js success alert" do
            expect(page.find("#fba-alert")).to have_content("Thank you. Your feedback has been received.")
          end
        end
      end
    end

    context "Recruiter Touchpoint" do
      before do
        visit example_admin_touchpoint_path(recruiter_touchpoint)
      end

      it "loads Badge with Text" do
        expect(page).to have_content("Help improve this site")
      end

      describe "clicking the Feedback Form tab" do
        before do
          click_on "fba-button"
        end

        it "opens Modal" do
          expect(page).to have_css("#fba-modal-dialog", visible: true)

          within "#fba-modal-dialog" do
            expect(page).to have_content "Do you have a few minutes to help us test this site?"
          end
        end

        describe "submit the form" do
          before "fill-in the form" do
            fill_in "answer_01", with: "Concerned Citizen"
            fill_in "answer_02", with: "test_public_user@example.com"
            fill_in "answer_03", with: "555-123-4567"
            click_button "Submit"
          end

          it "display .js success alert" do
            expect(page.find("#fba-alert")).to have_content("Thank you. Your feedback has been received.")
          end
        end
      end
    end

  end
end
