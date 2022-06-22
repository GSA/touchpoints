# frozen_string_literal: true

require 'rails_helper'

feature 'Profile', js: true do
  context 'as Admin' do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user:) }

    context 'not logged in' do
      describe '/profile' do
        before do
          visit profile_path
        end

        it 'redirects to root path with flash message' do
          expect(page.current_path).to eq(index_path)
          expect(page).not_to have_content('Your API Key was last updated more than')
        end
      end
    end

    describe '/profile' do
      before do
        login_as(user)
      end

      context 'with the api key not set' do
        before do
          visit profile_path
        end

        it 'enters an invalid (too short) new api key' do
          fill_in('user[api_key]', with: '123')
          click_on 'Update User'
          expect(page).to have_content('Api key is not 40 characters, as expected from api.data.gov.')
          expect(page.current_path).to have_content(profile_path)
        end

        it 'enters new, valid api key' do
          fill_in('user[api_key]', with: TEST_API_KEY)
          click_on 'Update User'
          expect(page).to have_content('User profile updated')
          expect(page.current_path).to have_content(profile_path)
        end
      end

      context 'with the api key set' do
        before do
          user.update(api_key: TEST_API_KEY)
          visit profile_path
        end

        it 'can enter blank key' do
          expect(page).to have_content('API Documentation')
          expect(page).to have_content('See the Touchpoints wiki for API documentation.')
          fill_in('user[api_key]', with: nil)
          click_on 'Update User'
          expect(page.current_path).to have_content(profile_path)
          expect(find('input#user_api_key').value).to eq('')
        end
      end
    end
  end
end
