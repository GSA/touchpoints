require 'rails_helper'

feature "Login Flow", js: true do

  describe "homepage" do
    context "invalid User (email)" do
      describe "Sign Up" do
        before "user completes Sign Up form" do
          visit new_user_registration_path
          fill_in "user[email]", with: "admin@dotcom.com"
          fill_in "user[password]", with: "password"
          fill_in "user[password_confirmation]", with: "password"
          click_button "Sign up"
        end

        it "redirect to homepage with a error flash message" do
          expect(page.current_path).to eq("/users")
          expect(page).to have_content("1 error prohibited this user from being saved:")
          expect(page).to have_content("Email is not from a valid TLD - .gov and .mil domains only")
        end
      end
    end

    context "valid User" do
      describe "Sign Up" do
        before "user completes Sign Up form" do
          visit new_user_registration_path
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
        it "redirect to homepage with a flash message" do
          expect(page.current_path).to eq("/users")
          expect(page).to have_content("Email was already confirmed, please try signing in")
        end
      end
    end

    describe "Sign In" do
      let(:user) { FactoryBot.create(:user) }

      before "user completes Sign Up form" do
        visit new_user_session_path
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
