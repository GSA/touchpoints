require 'rails_helper'

feature "Login Flow", js: true do

  let!(:organization) { FactoryBot.create(:organization) }

  describe "homepage" do
    context "invalid User (email from non .gov/.mil)" do
      describe "Sign Up" do
        before "user completes Sign Up form" do
          visit new_user_registration_path
          click_on "agree-button"
          fill_in "user[email]", with: "admin@nongov.com"
          fill_in "user[password]", with: "password"
          fill_in "user[password_confirmation]", with: "password"
          click_button "Sign up"
        end

        it "redirect to /users with a error flash message" do
          expect(page.current_path).to eq("/users")
          expect(page).to have_content("1 error prohibited this user from being saved:")
          expect(page).to have_content("Email is not from a valid TLD - .gov and .mil domains only")
        end
        # try a non .gov address
        # try a non-exi
      end
    end

    context "invalid User (email not for an existing Organization)" do
      describe "Sign Up" do
        before "user completes Sign Up form" do
          visit new_user_registration_path
          click_on "agree-button"
          fill_in "user[email]", with: "admin@new.gov"
          fill_in "user[password]", with: "password"
          fill_in "user[password_confirmation]", with: "password"
          click_button "Sign up"
        end

        it "redirect to /users with a error flash message" do
          expect(page.current_path).to eq("/users")
          expect(page).to have_content("1 error prohibited this user from being saved:")
          expect(page).to have_content("Organization 'new.gov' has not yet been configured for Touchpoints - Please contact the Feedback Analytics Team for assistance.")
        end
        # try a non .gov address
        # try a non-exi
      end
    end

    context "valid User" do
      describe "Sign Up" do
        before "user completes Sign Up form" do
          visit new_user_registration_path
          click_on "agree-button"
          fill_in "user[email]", with: "admin@example.gov"
          fill_in "user[password]", with: "password"
          fill_in "user[password_confirmation]", with: "password"
          click_button "Sign up"
        end

        # TODO
        # xit'd until emails are config'd
        xit "redirect to homepage with a flash message" do
          expect(page.current_path).to eq(root_path)
          expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
        end

        it "redirect to Dashboard with a flash message" do
          expect(page.current_path).to eq("/admin/dashboard")
          expect(page).to have_content("Welcome! You have signed up successfully.")
          expect(page).to_not have_content("Email was already confirmed")
        end
      end
    end

    xdescribe "Sign In" do
      let(:user) { FactoryBot.create(:user) }

      before "user completes Sign Up form" do
        visit new_user_session_path
        click_on "agree-button"
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        click_button "Log in"
      end

      it "redirect to homepage with a flash message" do
        expect(page.current_path).to eq(root_path)
        expect(page).to have_content("Signed in successfully.")
      end
    end
  end
end
