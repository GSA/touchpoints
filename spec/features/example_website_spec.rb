require 'rails_helper'

feature "Example Website Integration", js: true do

  describe "third-party .gov website" do
    before "foo" do
      visit example_path
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
          expect(accept_alert).to eq("Thank you - we will be in touch shortly!")
        end
      end
    end
  end
end
