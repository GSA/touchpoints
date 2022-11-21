# frozen_string_literal: true

require 'rails_helper'

feature 'Managing Websites', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let!(:website_manager) { FactoryBot.create(:user, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  let!(:website) { FactoryBot.create(:website, organization: organization, site_owner_email: website_manager.email) }
  let!(:new_website) { FactoryBot.build(:website, site_owner_email: website_manager.email) }

  context 'as Admin' do
    before do
      login_as admin
      visit admin_websites_path
    end

    it 'load the Websites#index page' do
      expect(page).to have_content('Inventorying Digital Assets')
      expect(page.current_path).to eq(admin_websites_path)
      expect(page).to have_content('New Website')
    end

    describe 'create a new Website' do
      before 'user fill-in the form' do
        click_on 'New Website'
        expect(page).to have_content('New Website')
        fill_in :website_domain, with: new_website.domain
        select(organization.abbreviation, from: 'website_organization_id')
        select('Application - Transactional', from: 'website_type_of_site')
        click_on 'Create Website'
      end

      it 'create Website successfully' do
        expect(page).to have_content('Website was successfully created.')
        expect(page).to have_content(new_website.domain)
      end

      it 'creates a version with user info after create' do
        website.reload
        expect(website.versions.size).to eq(1)
        expect(website.versions.last.event).to eq('create')
      end
    end

    describe 'track versions after edit' do
      before  do
        visit edit_admin_website_path(website)
        fill_in :website_office, with: 'Test Office'
        select('Application - Transactional', from: 'website_type_of_site')
        select('Login.gov', from: 'website_authentication_tool')
        select('Other', from: 'website_feedback_tool')
        click_on 'Update Website'
      end

      it 'creates a version with user info after update' do
        expect(page).to have_content('Test Office')
        website.reload
        expect(website.versions.size).to eq(2)
        expect(website.versions.last.event).to eq('update')
        expect(website.versions.last.whodunnit).to eq(admin.id.to_s)
      end
    end
  end

  context 'as Website Manager' do
    before 'visit Organization listing' do
      login_as website_manager
      visit admin_websites_path
    end

    it 'load the Websites#index page' do
      expect(page).to have_content('Inventorying Digital Assets')
      expect(page.current_path).to eq(admin_websites_path)
    end

    describe 'create a new Website' do
      before 'user fill-in the form' do
        click_on 'New Website'
        expect(page).to have_content('New Website')
        select(organization.abbreviation, from: 'website_organization_id')
        fill_in :website_domain, with: new_website.domain
        select('Application - Transactional', from: 'website_type_of_site')
        click_on 'Create Website'
      end

      it 'create Website successfully' do
        expect(page).to have_content('Website was successfully created.')
        expect(page).to have_content(new_website.domain)
      end
    end
  end

  context 'as a user who does not own a Website and is not a Website Admin' do
    before do
      login_as user
      visit admin_websites_path
    end

    it 'load the Websites#index page' do
      expect(page).to have_content('Inventorying Digital Assets')
      expect(page.current_path).to eq(admin_websites_path)

      click_on 'New Website'
      expect(page).to have_content('New Website')
    end

    describe 'create a new Website' do
      before do
        visit new_admin_website_path
        expect(page).to have_content('New Website')
        fill_in :website_domain, with: new_website.domain
        select(organization.abbreviation, from: 'website_organization_id')
        select('Application - Transactional', from: 'website_type_of_site')
        click_on 'Create Website'
      end

      it 'create Website successfully' do
        expect(page).to have_content('Website was successfully created.')
        expect(page).to have_content(new_website.domain)
      end
    end

    describe "editing another's Website" do
      before do
        visit admin_websites_path
        click_on website.domain
      end

      it 'can view successfully but not see an edit button' do
        expect(page).to have_content("Website: #{website.domain}")
        expect(page).to_not have_content('Edit')
      end
    end

    describe "trying to edit another's Website" do
      before 'user fill-in the form' do
        visit edit_admin_website_path(website)
      end

      it 'redirect to /admin/websites' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq(admin_websites_path)
      end
    end
  end
end
