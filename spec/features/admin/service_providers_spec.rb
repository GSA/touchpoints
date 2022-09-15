# frozen_string_literal: true

require 'rails_helper'

feature 'Service Provider', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }

  context 'as Admin' do
    before do
      login_as admin
    end

    describe '#index' do
      before do
        visit admin_service_providers_path
      end

      it 'load the ServiceProviders#index page' do
        expect(page).to have_content('Service Providers')
        expect(page.current_path).to eq(admin_service_providers_path)
        expect(page).to have_content(service_provider.name)
        expect(page).to have_content('Download as hisps.csv')
      end
    end

    describe '#edit' do
      before do
        visit edit_admin_service_provider_path(service_provider)
      end

      it 'load the ServiceProviders#index page' do
        fill_in "service_provider_cx_maturity_mapping_value", with: 5
        fill_in "service_provider_impact_mapping_value", with: 55
        click_on 'Update Service provider'
        expect(page).to have_content('Service provider was successfully updated.')
      end
    end
  end
end
