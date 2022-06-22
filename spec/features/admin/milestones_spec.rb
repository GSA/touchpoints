# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/milestones', js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let!(:milestones) { FactoryBot.create_list(:milestone, 3, organization:) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  context 'logged in as admin' do
    before do
      login_as(admin)
    end

    describe 'GET /index' do
      it 'display a list of milestones' do
        expect(milestones.size).to eq(3)
        visit admin_milestones_path

        expect(page).to have_content(milestones.first.name)
        expect(page).to have_content(milestones.last.name)
        expect(page).to have_link('New Milestone')
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
        visit new_admin_milestone_path
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
        visit admin_milestones_path
      end

      it 'redirect and display unauthorized flash' do
        expect(page).to have_content('Authorization is Required')
        expect(page.current_path).to eq(index_path)
      end
    end
  end
end
