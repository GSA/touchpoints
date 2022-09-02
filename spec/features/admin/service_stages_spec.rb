# frozen_string_literal: true

require 'rails_helper'

feature 'Service Stages', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:service_owner) { FactoryBot.create(:user, organization:) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: service_owner.id) }
  let!(:service2) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: admin.id) }
  let!(:persona) { FactoryBot.create(:persona, name: 'Federal Staff User') }

  before do
    service2.tag_list.add('feature-request')
    service2.tag_list.add('policy')
    service2.save
  end

  context 'as Admin' do
    before do
      login_as admin
      visit admin_service_service_stages_path(service2)
    end

    describe 'add Service Stage' do
      before do
        click_on 'Add Stage'
        expect(page).to have_content('New Service Stage:')
        fill_in 'service_stage_name', with: 'New Stage'
        fill_in 'service_stage_description', with: 'New Stage Description'
        fill_in 'service_stage_position', with: '1000'
        select persona.name, from: 'service_stage_persona_id'
        click_on 'Create Service stage'
      end

      it 'newly created tag is displayed on the page' do
        expect(page).to have_content('Service stage was successfully created.')
        expect(page).to have_content("Customer type: #{persona.name}")
      end
    end
  end

  context 'as Service Owner' do
    before do
      login_as service_owner
      visit admin_service_service_stages_path(service)
    end

    describe 'add Service Stage' do
      before do
        click_on 'Add Stage'
        expect(page).to have_content('New Service Stage:')
        fill_in 'service_stage_name', with: 'New Stage'
        fill_in 'service_stage_description', with: 'New Stage Description'
        fill_in 'service_stage_position', with: '1000'
        click_on 'Create Service stage'
      end

      it 'newly created tag is displayed on the page' do
        expect(page).to have_content('Service stage was successfully created.')
      end
    end
  end
end
