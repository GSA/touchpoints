# frozen_string_literal: true

require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe '/omb_cx_reporting_collections', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }
  let!(:collection) { FactoryBot.create(:collection, organization:, user:, service_provider:) }
  let(:omb_cx_reporting_collection) { FactoryBot.create(:omb_cx_reporting_collection, collection:, service:) }

  before do
    login_as(admin)
  end

  describe 'GET /show' do
    before do
      visit admin_omb_cx_reporting_collection_path(omb_cx_reporting_collection)
    end

    it 'renders a successful response' do
      expect(page).to have_content('CX service reporting worksheet')
      expect(page).to have_content('Satisfaction')
      expect(page).to have_content('Trust or Confidence')
    end

    describe 'navigate to /edit' do
      before do
        click_on 'Edit'
      end

      it 'load /edit successfully' do
        expect(page).to have_content('Editing CX service reporting worksheet')
      end
    end
  end

  describe 'GET /new' do
    before do
      visit new_admin_omb_cx_reporting_collection_path
    end

    it 'renders a successful response' do
      expect(page).to have_content('New Omb Cx Reporting Collection')
    end

    describe 'update an omb cx reporting collection' do
      before do
        select(collection.name, from: 'omb_cx_reporting_collection_collection_id')
        select(service.name, from: 'omb_cx_reporting_collection_service_id')
        fill_in :omb_cx_reporting_collection_service_provided, with: 'Description of your service'
        click_on 'Update CX Service Detail Report'
      end

      it 'display successful flash message' do
        expect(page).to have_content("CX service reporting worksheet")
        expect(find('.usa-alert__text')).to have_content('Omb cx reporting collection was successfully created.')
      end
    end

    describe 'heartbeat' do
      it "form blurs send an ActiveSignal to keep the user's session active" do
        select(collection.name, from: 'omb_cx_reporting_collection_collection_id')
        select(service.name, from: 'omb_cx_reporting_collection_service_id')
        fill_in :omb_cx_reporting_collection_service_provided, with: 'Description of your service'
        # Pause 10 mins in between a UI interaction
        travel 10.minutes
        # trigger a blur
        execute_script("$('#omb_cx_reporting_collection_transaction_point').blur()")
        # wait for a response, because there is no UI indicator to assert for
        sleep 1.0

        travel 14.minutes
        click_on 'Update CX Service Detail Report'
        wait_for_ajax
        expect(find('.usa-alert__text')).to have_content('Omb cx reporting collection was successfully created.')
      end
    end
  end

  describe 'GET /edit' do
    before do
      visit edit_admin_omb_cx_reporting_collection_path(omb_cx_reporting_collection)
      click_on 'Update CX Service Detail Report'
    end

    it 'render a successful response' do
      expect(find('.usa-alert__text')).to have_content('Omb cx reporting collection was successfully updated.')
    end
  end
end
