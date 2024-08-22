# frozen_string_literal: true

require 'rails_helper'

feature 'CSCRM Collections', js: true do
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
        visit new_admin_cscrm_data_collection_path

        select(organization.name, from: 'cscrm_data_collection_organization_id')
        fill_in("cscrm_data_collection_bureau", with: "Bureau Name")
        fill_in("cscrm_data_collection_year", with: "2023")
        fill_in("cscrm_data_collection_quarter", with: "1")
        select("Yes", from: 'cscrm_data_collection_interdisciplinary_team_established')
        fill_in("cscrm_data_collection_interdisciplinary_team_established_comments", with: "c4")
        select("Yes", from: 'cscrm_data_collection_pmo_established')
        fill_in("cscrm_data_collection_pmo_established_comments", with: "c5")
        select("Yes", from: 'cscrm_data_collection_enterprise_wide_scrm_policy_established')
        fill_in("cscrm_data_collection_enterprise_wide_scrm_policy_established_comments", with: "c6")
        select("Partially secured", from: 'cscrm_data_collection_funding_for_initial_operating_capability')
        fill_in("cscrm_data_collection_funding_for_initial_operating_capability_comments", with: "c7")
        select("Partially secured", from: 'cscrm_data_collection_staffing')
        fill_in("cscrm_data_collection_staffing_comments", with: "c8")
        select("No", from: 'cscrm_data_collection_agency_wide_scrm_strategy_and_implementation_plan_established')
        fill_in("cscrm_data_collection_agency_wide_scrm_strategy_and_implementation_plan_comments", with: "c9")
        select("Not established", from: 'cscrm_data_collection_enterprise_risk_management_function_established')
        fill_in("cscrm_data_collection_enterprise_risk_management_function_established_comments", with: "c10")
        select("Yes", from: 'cscrm_data_collection_prioritization_process')
        fill_in("cscrm_data_collection_prioritization_process_comments", with: "c11")
        click_on "Create CSCRM Data Collection"
      end

      it 'is accessible' do
        expect(page).to be_axe_clean
      end

      it 'creates a Collection successfully' do
        expect(page).to have_content('Cscrm data collection was successfully created.')
      end
    end
  end
end
