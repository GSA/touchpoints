require 'rails_helper'

feature "Profile", js: true do
  context "as Admin" do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user) }

	describe "/profile" do

	    before do
	      login_as(user)
	    end

		context "api key" do
			it 'shows no warning if api key has not been generated' do
			  visit profile_path
			  expect(page).to have_content("Generate API Key")
			  expect(page).not_to have_content("Your API Key was last updated more than")
			end

			it 'shows no warning if api key exists and has been updated within 6 months' do
			  user.set_api_key
			  visit profile_path
			  expect(page).to have_content("Remove API Key")
			  expect(page).not_to have_content("Your API Key was last updated more than")
			end

			it 'shows warning if api key exists and has been updated within 6 months' do
			  user.set_api_key
			  user.update(api_key_update_date: 1.year.ago)
			  visit profile_path
			  expect(page).to have_content("Remove API Key")
			  expect(page).to have_content("Your API Key was last updated more than")
			end
		end
	end
  end
end