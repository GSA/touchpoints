# frozen_string_literal: true

require 'rails_helper'

feature 'CSCRM Collections 2', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:another_organization) { FactoryBot.create(:organization, :another) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  context 'as an Admin' do
    before do
      login_as(user)
    end

    describe 'GET /new' do

      before do
        visit new_admin_cscrm_data_collections2_path

        select(organization.name, from: 'cscrm_data_collection2_organization_id')
        fill_in("cscrm_data_collection2_bureau", with: "Bureau Name")
        fill_in("cscrm_data_collection2_year", with: "2023")
        fill_in("cscrm_data_collection2_quarter", with: "3")

        # Question 1
        select("Yes", from: 'cscrm_data_collection2_interdisciplinary_team')
        select("Yes", from: 'cscrm_data_collection2_supply_chain_acquisition_procedures')
        select("Fully identified and secured", from: 'cscrm_data_collection2_funding')
        select("Fully identified and secured", from: 'cscrm_data_collection2_identified_staff')
        select("Yes", from: 'cscrm_data_collection2_strategy_plan')
        select("Not established", from: 'cscrm_data_collection2_governance_structure')
        select("Yes", from: 'cscrm_data_collection2_prioritization_process')
        select("In development", from: 'cscrm_data_collection2_documented_methodology')

        click_on "Create CSCRM Data Collection"
      end

      it 'is accessible' do
        expect(page).to be_axe_clean
      end

      it 'creates a Collection successfully' do
        expect(page).to have_content('CSCRM Data Collection 2')
        expect(page).to have_content('Cscrm data collection was successfully created.')
        expect(page).to have_content('20. Comments')
      end
    end
  end
end
