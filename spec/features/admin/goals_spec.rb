# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/goals', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let!(:goals) { FactoryBot.create_list(:goal, 3, organization:) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  context 'logged in as admin' do
    before do
      login_as(admin)
    end

    describe 'GET /index' do
      it 'display a list of goals' do
        visit admin_goals_path

        expect(page).to have_content(goals.first.organization.name)
        expect(page).to have_content(goals.first.name)
        expect(page).to have_content(goals.last.name)
        expect(page).to have_link('New Strategic Goal')
      end
    end

    describe 'add organization' do
      let(:goal) { FactoryBot.create(:goal) }

      before 'fill-in the form' do
        visit admin_goal_path(goal)

        select(organization.name, from: 'organization_id')
        find('.organizations').click # just to lose focus
      end

      it 'creates an organization' do
        expect(page).to have_css('.usa-tag', text: organization.name.upcase)
      end
    end

    describe 'remove organization' do
      let(:goal) { FactoryBot.create(:goal) }

      before 'fill-in the form' do
        goal.organization_list.add(organization.id)
        visit admin_goal_path(goal)
        select(organization.name, from: 'organization_id')
        expect(page).to have_content(organization.name.upcase)
        find('.remove-tag-link').click
      end

      it 'removes the organization' do
        expect(page).to_not have_content(organization.name.upcase)
      end
    end
  end

  context 'logged in as a non-permissioned user' do
    let(:user) { FactoryBot.create(:user, organization:) }

    before do
      login_as(user)
    end

    describe 'tries to visit a path requiring performance manager permissions' do
      before do
        visit new_admin_goal_path
      end

      it 'redirects to default admin path due to lack of permissions' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq(admin_root_path)
      end
    end
  end

  context 'not logged in' do
    describe 'GET /index' do
      before do
        visit admin_goals_path
      end

      it 'redirect and display unauthorized flash' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq(index_path)
      end
    end
  end
end
