# frozen_string_literal: true

require 'rails_helper'

feature 'CX Data Collections', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:another_organization) { FactoryBot.create(:organization, :another) }
  let!(:another_service_provider) { FactoryBot.create(:service_provider, organization: another_organization, name: 'Another HISP') }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization: another_organization) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider: service_provider, hisp: true, service_owner_id: user.id) }

  let!(:service_provider2) { FactoryBot.create(:service_provider, organization:, name: "Another service provider") }
  let!(:service2) { FactoryBot.create(:service, organization:, service_provider: service_provider2, name: "Another public service", hisp: true, service_owner_id: user.id) }

  let!(:cx_collection) { FactoryBot.create(:cx_collection, organization: another_organization, user:, service_provider: another_service_provider, service: service) }
  let!(:cx_collection_detail) { FactoryBot.create(:cx_collection_detail, cx_collection: cx_collection, service: service, transaction_point: :post_service_journey, channel: Service.channels.sample) }

  let!(:admin_cx_collection) { FactoryBot.create(:cx_collection, organization:, user: admin, service: service, service_provider:) }

  context 'as an Admin' do
    before do
      login_as(admin)
    end

    describe 'GET /index' do
      let!(:cx_collection_1) { FactoryBot.create(:cx_collection, organization:, user: admin, service_provider: service_provider, service: service, fiscal_year: 2021, quarter: 2) }
      let!(:cx_collection_2) { FactoryBot.create(:cx_collection, organization:, user: admin, service_provider: service_provider2, service: service2, fiscal_year: 2022, quarter: 1) }
      let!(:cx_collection_3) { FactoryBot.create(:cx_collection, organization:, user: admin, service_provider: service_provider, service: service, fiscal_year: 2022, quarter: 1) }

      before do
        visit admin_cx_collections_path
      end

      it 'renders the index page and summary table' do
        expect(page).to have_content('CX Data Collections')
        within ('table.usa-table.collections-summary') do
          expect(page).to have_content('Active HISP Services')
          expect(page).to have_content('Total Collections')
          expect(page).to have_content('Draft')
          expect(page).to have_content('Submitted')
          expect(page).to have_content('Published')
          expect(page).to have_content('Non-reporting')
          expect(page).to have_content('Change Requested')
        end
      end

      it 'can filter Collections by year' do
        expect(page).to have_content('Filter by fiscal year and quarter')
        expect(page).to have_content('Q1')
      end

      describe 'filter by year and quarter' do
        before do
          expect(page).to have_css(".usa-table.collections tbody tr", count: 5)
          select("2024", from: "year")
          select("1", from: "quarter")
          click_on("Filter")
          expect(page).to have_content("for Q1 2024")
        end

        it 'find the two 2024 Q1 collections' do
          expect(page).to have_css(".usa-table.collections tbody tr", count: 2)
        end
      end
    end

    describe 'GET /show' do
      before do
        visit admin_cx_collection_path(cx_collection)
      end

      it 'renders a successful response' do
        expect(page).to have_content('CX Data Collection')
        expect(page).to have_content(cx_collection.name)
      end
    end

    describe 'GET /new' do
      before do
        visit new_admin_cx_collection_path
      end

      it 'renders page' do
        expect(page).to have_content('New Data Collection')
        expect(page).to have_button('Create Cx collection')
      end

      context 'with valid parameters' do
        let(:current_year) { Time.zone.now.strftime('%Y') }

        before do
          select(service_provider.name, from: 'cx_collection_service_provider_id')
          select(service.name, from: 'cx_collection_service_id')
          select(current_year, from: 'cx_collection_fiscal_year')
          select(4, from: 'cx_collection_quarter')
          wait_for_ajax
          click_on 'Create Cx collection'
        end

        it 'creates a new CX Collection' do
          expect(page).to have_content('ABOUT THIS DATA COLLECTION')
          expect(page).to have_content('CX Quarterly Reporting')
          expect(page.current_path).to eq(admin_cx_collection_path(CxCollection.last))
          expect(page).to have_link('Add detail record')
        end
      end
    end

    describe '/collections/:id/edit' do
      context 'with valid parameters' do
        before do
          visit edit_admin_cx_collection_path(cx_collection)
          expect(page).to have_content('Editing CX Data Collection')
          select(4, from: 'cx_collection_quarter')
          click_on 'Update Cx collection'
        end

        it 'update the requested collection' do
          expect(page).to have_content('CX Data Collection was successfully updated.')
          expect(page.current_path).to eq(admin_cx_collection_path(cx_collection))
        end
      end

      context 'with invalid parameters' do
        xit '' do
        end
      end
    end

    describe 'DELETE /destroy' do
      before do
        visit edit_admin_cx_collection_path(cx_collection)
        expect(page).to have_content('Editing CX Data Collection')
        click_on 'Delete'
        page.driver.browser.switch_to.alert.accept
      end

      it 'destroys the requested collection' do
        expect(page).to have_content('Data Collections')
        expect(page).to have_content('CX Data Collection was successfully destroyed.')
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
        visit admin_cx_collections_path
      end

      it 'renders the index page' do
        expect(page).to have_content('Data Collections')
        expect(page).to have_css('table.usa-table')
      end
    end

    describe 'GET /show' do
      let(:collection) { FactoryBot.create(:collection, organization: another_organization, user:, service_provider: another_service_provider) }

      it 'renders a successful response' do
        visit admin_cx_collection_path(cx_collection)
        expect(page).to have_content('Data Collections')
      end
    end

    describe 'GET /edit' do
      before do
        visit edit_admin_cx_collection_path(cx_collection)
      end

      it 'renders a successful response' do
        expect(page).to have_content('Editing CX Data Collection')
      end

      it "renders Collection dropdown with 1 organization's collections" do
        expect(page.all('select#cx_collection_name option').count).to eq(1)
      end

      context '#copy' do
        before do
          click_on 'Copy this collection'
          page.driver.browser.switch_to.alert.accept
        end

        it 'renders a successful response' do
          expect(page).to have_content('CX Data Collection was successfully copied.')
          expect(page).to have_content("Copy of #{cx_collection.name}")
        end
      end
    end
  end
end
