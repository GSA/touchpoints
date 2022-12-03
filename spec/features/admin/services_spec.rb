# frozen_string_literal: true

require 'rails_helper'

feature 'Managing Services', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }
  let!(:service2) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: admin.id) }

  before do
    service2.tag_list.add('feature-request')
    service2.tag_list.add('policy')
    service2.save
  end

  context 'as Admin' do
    before do
      login_as admin
    end

    describe '#index' do
      before do
        visit admin_services_path
      end

      it 'load the Services#index page' do
        expect(page).to have_content('Managing Services in Touchpoints')
        expect(page.current_path).to eq(admin_services_path)
        expect(page).to have_link('New Service')
        expect(page).to have_css('tbody tr', count: 2)
      end

      describe 'create a new Service' do
        before 'fill-in the form' do
          click_on 'New Service'
          expect(page).to have_content('New Service')
          select(organization.name, from: 'service[organization_id]')
          fill_in :service_name, with: 'New Service Name'
          fill_in :service_description, with: "Lots of text\n\n#### Heading\n\n* 1\n* 2\n* 3"

          find("label[for='service_hisp']").click
          select(service_provider.name, from: 'service[service_provider_id]')
          click_on 'Create Service'
        end

        it 'create Service successfully' do
          expect(page).to have_content('Service was successfully created')
          expect(page).to have_content('New Service Name')

          # renders markdown
          expect(page).to have_css('h4', text: 'Heading')
          expect(page).to have_css('ul li', text: '2')
        end
      end
    end

    describe 'add a tag to a Service' do
      before 'add the tag' do
        visit admin_service_path(service2)
        fill_in 'service_tag_list', with: 'new-tag'
        find('body').click # to create the tag
      end

      it 'newly created tag is displayed on the page' do
        expect(page).to have_css('.usa-tag', text: 'NEW-TAG')
      end
    end

    describe 'search by Tag' do
      before do
        visit admin_services_path
        find('.usa-tag', text: 'FEATURE-REQUEST').click # to select the services with the tag
      end

      it 'newly created tag is displayed on the page' do
        expect(page).to have_css('tbody tr', count: 1)
        expect(page.current_url).to include('tag=feature-request')
      end
    end

    describe 'Service Managers' do
      before do
        visit edit_admin_service_path(service)
        find("label[for='service_hisp']").click
        select(admin.email, from: 'service_manager_id')
      end

      it "display new service manager's email as a tag" do
        expect(page).to have_css('.usa-tag', text: admin.email.upcase)
      end
    end

    describe 'Channels' do
      before do
        visit edit_admin_service_path(service)
        select(Service.channels.first, from: 'channel_id')
      end

      it 'displays new channel as a tag' do
        expect(page).to have_css('.usa-tag', text: Service.channels.first.to_s.upcase)
      end
    end
  end
end
