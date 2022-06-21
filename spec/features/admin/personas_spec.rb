# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Personas', js: true do
  let!(:new_organization) { FactoryBot.build(:organization, name: 'New Org') }

  let!(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  context 'as Admin' do
    before do
      login_as admin
    end

    describe '#index' do
      before do
        visit admin_personas_path
      end

      it 'display page content' do
        expect(page).to have_content('Personas')
        expect(page).to have_link('New Persona')
      end
    end

    describe '#new' do
      before do
        visit new_admin_persona_path

        fill_in 'persona_name', with: 'Test Persona'
        fill_in 'persona_description', with: 'Description of persona'
        fill_in 'persona_notes', with: 'Description of persona'
        click_on 'Create Persona'
      end

      it 'display success message on #show' do
        expect(page).to have_content('Persona was successfully created.')
      end
    end
  end
end
