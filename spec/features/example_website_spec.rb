require 'rails_helper'

feature "Example Website Integration", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let!(:touchpoint) { FactoryBot.create(:touchpoint) }

  describe "third-party .gov website" do
    before "foo" do
      login_as(admin)
      visit example_touchpoint_path(touchpoint)
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

      describe "submit the Feedback Form" do
        before "fill-in the form" do
          fill_in "fba-text-name", with: "Concerned Citizen"
          fill_in "fba-text-email", with: "test_public_user@example.com"
          fill_in "fba-text-phone", with: "555-123-4567"
          click_button "Send"
        end

        it "display .js success alert" do
          expect(page.find("#fba-alert")).to have_content("Success! Form submitted successfully. Thank you for your Feedback.")
        end
      end
    end
  end
end
