# frozen_string_literal: true

require 'rails_helper'

feature 'Managing Organizations', js: true do
  let!(:new_organization) { FactoryBot.build(:organization, name: 'New Org', abbreviation: 'NEWORG') }

  let!(:organization) { FactoryBot.create(:organization) }
  let!(:organization2) { FactoryBot.create(:organization, name: 'Organization 2', domain: 'test.gov', abbreviation: 'ORG2') }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:service) { FactoryBot.create(:service, organization:, service_owner_id: user.id) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:cx_collection) { FactoryBot.create(:cx_collection, organization:, service_provider:, service:) }

  context 'as Admin' do
    before 'visit Organization listing' do
      login_as admin
      visit admin_organizations_path
    end

    it 'is accessible' do
      expect(page).to be_axe_clean
    end

    it 'display Admin-specific UI content' do
      expect(page).to have_link(Organization.first.name)
      expect(page).to have_link('New Organization')
    end

    describe 'create an Organization' do
      before do
        click_on 'New Organization'

        fill_in :organization_name, with: new_organization.name
        fill_in :organization_domain, with: new_organization.domain
        fill_in :organization_url, with: new_organization.url
        fill_in :organization_abbreviation, with: new_organization.abbreviation
        fill_in :organization_notes, with: new_organization.notes

        click_on 'Create Organization'
      end

      it 'successfully creates an Organization' do
        expect(page).to have_content('Organization was successfully created.')
      end
    end

    describe 'view an existig Organization' do
      before do
        visit admin_organization_path(organization)
      end

      it 'successfully displays an Organization and its contents' do
        binding.pry
        expect(page).to have_content('No parent organization specified')
        expect(page).to have_content('0 Sub-agencies')
        expect(page).to have_content('1 Service Providers')
        expect(page).to have_content('1 Service')
        expect(page).to have_link('Service to deliver to customer')
      end

      it 'is accessible' do
        expect(page).to be_axe_clean
      end
    end
  end
end
