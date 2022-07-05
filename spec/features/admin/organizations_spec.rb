# frozen_string_literal: true

require 'rails_helper'

feature 'Managing Organizations', js: true do
  let!(:new_organization) { FactoryBot.build(:organization, name: 'New Org', abbreviation: 'NEWORG') }

  let!(:organization) { FactoryBot.create(:organization) }
  let!(:organization2) { FactoryBot.create(:organization, name: 'Organization 2', domain: 'test.gov', abbreviation: 'ORG2') }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  context 'as Admin' do
    before 'visit Organization listing' do
      login_as admin
      visit admin_organizations_path
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

    describe 'sort goals' do
      let!(:goal_list) { FactoryBot.create_list(:goal, 3, organization:) }

      it 'successfully re-orders goals for an organization' do
        visit performance_admin_organization_path(organization)
        goal_list.each do |goal|
          expect(goal.position).to eq(0)
        end
        find('#goal_3').drag_to(find('#goal_1'))
        wait_for_ajax
        expect(goal_list[0].reload.position).to eq(2)
        expect(goal_list[1].reload.position).to eq(3)
        expect(goal_list[2].reload.position).to eq(1)
      end
    end

    describe 'sort objectives' do
      let!(:goal) { FactoryBot.create(:goal, organization:, four_year_goal: true) }
      let!(:objective_list) { FactoryBot.create_list(:objective, 3, goal:, organization:) }

      it 'successfully re-orders objectivs for a goal' do
        visit performance_admin_organization_path(organization)
        objective_list.each do |obj|
          expect(obj.position).to eq(0)
        end
        find('#objective_3').drag_to(find('#objective_1'))
        wait_for_ajax
        expect(objective_list[0].reload.position).to eq(2)
        expect(objective_list[1].reload.position).to eq(3)
        expect(objective_list[2].reload.position).to eq(1)
      end
    end
  end
end
