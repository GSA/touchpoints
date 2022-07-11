# frozen_string_literal: true

require 'rails_helper'

feature 'Digital Products', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: admin.id) }

  let!(:digital_product) { FactoryBot.create(:digital_product, name: 'Test1', service: 'Facebook', aasm_state: 'published') }
  let!(:digital_product_2) { FactoryBot.create(:digital_product, aasm_state: 'created') }

  context 'as Admin' do
    before do
      login_as admin
    end

    describe '#index' do
      before do
        visit admin_digital_products_path
      end

      it 'load the DigitalProducts#index page' do
        expect(page).to have_content('Mobile Applications')
        expect(page).to have_link('New Mobile App')
        expect(page.current_path).to eq(admin_digital_products_path)
        expect(page).to have_css('tbody tr', count: 2)
      end
    end

    describe '#search' do
      before do
        visit admin_digital_products_path
      end

      it 'can search by keyword' do
        fill_in :tags, with: digital_product.name
        find('#tags').native.send_key :tab
        expect(page).to have_css('tbody tr', count: 1)
      end

      it 'can search by organization' do
        digital_product.organization_list.add(organization.id)
        digital_product.save
        select(organization.name, from: 'organization_id')
        expect(page).to have_css('tbody tr', count: 1)
      end

      it 'can search by service' do
        select('Facebook', from: 'service')
        expect(page).to have_css('tbody tr', count: 1)
      end

      it 'can search by aasm_state' do
        select('Published', from: 'aasm_state')
        expect(page).to have_css('tbody tr', count: 1)
      end
    end
  end
end
