# frozen_string_literal: true

require 'rails_helper'

feature 'general site navigation', js: true do
  context 'as Admin' do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, :admin, organization:) }

    before do
      login_as(user)
      visit root_path
    end

    context 'logged in' do
      describe '/admin/services' do
        before do
          click_on 'Services'
        end

        it 'renders successfully' do
          expect(page).to have_content('Services')
          expect(page).to have_content('New Service')
          expect(page.current_path).to eq(admin_services_path)
        end
      end

      describe '/admin/registry' do
        before do
          click_on 'Digital Registry'
        end

        it 'renders successfully' do
          expect(page).to have_content('U.S. Digital Registry')
        end
      end

      describe '/admin/websites' do
        before do
          click_on 'Digital Registry'
        end

        it 'renders successfully' do
          expect(page).to have_content('U.S. Digital Registry')
          click_on 'View Websites'
          expect(page).to have_content('New Website')
          expect(page.current_path).to eq(admin_websites_path)
        end
      end

      describe '/admin/reporting' do
        before do
          click_on 'Performance'
        end

        it 'renders successfully' do
          expect(page).to have_content('Performance management')
          expect(page.current_path).to eq(admin_performance_path)
        end
      end

      describe '/admin/collections' do
          before do
            visit admin_performance_path
            click_on 'CX Data Collection'
          end

          it 'renders successfully' do
            expect(page).to have_content('Data Collections')
            expect(page).to have_content('New Data Collection')
            expect(page.current_path).to eq(admin_collections_path)
          end
        end
    end
  end
end
