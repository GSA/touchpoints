# frozen_string_literal: true

require 'rails_helper'

feature 'Data Collections', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:another_organization) { FactoryBot.create(:organization, :another) }
  let!(:another_service_provider) { FactoryBot.create(:service_provider, organization: another_organization, name: 'Another HISP') }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization: another_organization) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, hisp: true, service_owner_id: user.id) }
  let!(:collection) { FactoryBot.create(:collection, organization: another_organization, user:, service_provider: another_service_provider) }
  let!(:admin_collection) { FactoryBot.create(:collection, organization:, user: admin, service_provider:) }

  context 'as an Admin' do
    before do
      login_as(admin)
    end

    describe 'GET /index' do
      let!(:collection_1) { FactoryBot.create(:collection, organization:, user: admin, service_provider:, year: 2021, quarter: 2) }
      let!(:collection_2) { FactoryBot.create(:collection, organization:, user: admin, service_provider:, year: 2022, quarter: 1) }
      let!(:collection_3) { FactoryBot.create(:collection, organization:, user: admin, service_provider:, year: 2022, quarter: 1) }

      before do
        visit admin_collections_path
      end

      it 'renders the index page' do
        expect(page).to have_content('Data Collections')
        expect(page).to have_css('table.usa-table')
      end

      it 'can filter Collections by year' do
        expect(page).to have_content('Filter by fiscal year and quarter')
        expect(page).to have_content('Q1')
        expect(page).to have_content('Q2')
        expect(page).to have_content('Q3')
        expect(page).to have_content('Q4')
      end

      describe 'filter for this year' do
        before do
          within(".year[data-id='2021']") do
            click_link('Q2')
            # Wait for page to reload and have the selected button (no outline)
            expect(page).not_to have_selector('a.usa-button--outline', text: 'Q2')
          end
        end

        it 'find the two (2) 2021 Q2 collections' do
          expect(find_all('table.collections tbody tr').size).to eq(3)
        end
      end

      describe 'filter for next year' do
        before do
          within(".year[data-id='2022']") do
            click_link('Q1')
            # Wait for page to reload and have the selected button (no outline)
            expect(page).not_to have_selector('a.usa-button--outline', text: 'Q1')
          end
        end

        it 'find the one (1) 2022 Q1 collection' do
          expect(find_all('table.collections tbody tr').size).to eq(2)
        end
      end
    end

    describe 'GET /show' do
      before do
        visit admin_collection_path(collection)
      end

      it 'renders a successful response' do
        expect(page).to have_content('Data Collection')
        expect(page).to have_content(collection.name)
        expect(page).to have_content('Reflection text')
      end
    end

    describe 'GET /new' do
      before do
        visit new_admin_collection_path
      end

      it 'renders page' do
        expect(page).to have_content('New Data Collection')
        expect(page).to have_button('Create Collection')
      end

      context 'with valid parameters' do
        let(:current_year) { Time.zone.now.strftime('%Y') }

        before do
          select(organization.name, from: 'collection_organization_id')
          select(service_provider.name, from: 'collection_service_provider_id')
          fill_in('collection_year', with: current_year)
          fill_in('collection_reflection', with: 'What we learned...')
          wait_for_ajax
          click_on 'Create Collection'
        end

        it 'creates a new Collection' do
          expect(page).to have_content('ABOUT THIS DATA COLLECTION')
          expect(page).to have_content('CX Quarterly Reporting')
          expect(page.current_path).to eq(admin_collection_path(Collection.last))
          expect(page).to have_link('Add a Service to report on')
          # TODO:  Sometimes content in the notice area isn't visible
          # expect(page).to have_content("Collection was successfully created.")
        end
      end
    end

    describe '/collections/:id/edit' do
      context 'with valid parameters' do
        before do
          visit edit_admin_collection_path(collection)
          click_on 'Update Collection'
        end

        it 'update the requested collection' do
          expect(page).to have_content('Collection was successfully updated.')
          expect(page.current_path).to eq(admin_collection_path(collection))
        end
      end

      context 'with invalid parameters' do
        xit '' do
        end
      end
    end

    describe 'DELETE /destroy' do
      before do
        visit edit_admin_collection_path(collection)
        expect(page).to have_content('Editing Data Collection')
        click_on 'Delete'
        page.driver.browser.switch_to.alert.accept
      end

      it 'destroys the requested collection' do
        expect(page).to have_content('Data Collections')
        expect(page).to have_content('Collection was successfully destroyed.')
      end
    end
  end

  context 'as a non-admin User' do
    let(:user2) { FactoryBot.create(:user, organization: another_organization) }

    before do
      login_as(user)
    end

    describe 'GET /index' do
      before do
        visit admin_collections_path
      end

      it 'renders the index page' do
        expect(page).to have_content('Data Collections')
        expect(page).to have_css('table.usa-table')
      end
    end

    describe 'GET /show' do
      let(:collection) { FactoryBot.create(:collection, organization: another_organization, user:, service_provider: another_service_provider) }

      it 'renders a successful response' do
        visit admin_collection_path(collection)
        expect(page).to have_content('Data Collections')
      end
    end

    describe 'GET /edit' do
      before do
        visit edit_admin_collection_path(collection)
      end

      it 'renders a successful response' do
        expect(page).to have_content('Editing Data Collection')
      end

      it "renders Collection dropdown with 1 organization's collections" do
        expect(page.all('select#collection_name option').count).to eq(1)
      end

      context '#copy' do
        before do
          click_on 'Copy this collection'
          page.driver.browser.switch_to.alert.accept
        end

        it 'renders a successful response' do
          expect(page).to have_content('Collection was successfully copied.')
          expect(page).to have_content("Copy of #{collection.name}")
        end
      end
    end
  end
end
