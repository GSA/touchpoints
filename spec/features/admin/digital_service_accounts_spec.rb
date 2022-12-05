# frozen_string_literal: true

require 'rails_helper'

feature 'Digital Service Accounts', js: true do
  let!(:organization) { FactoryBot.create(:organization) }

  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:user) { FactoryBot.create(:user, organization:) }

  context 'as Admin' do
    before do
      login_as admin
    end

    context 'with no records' do
      describe '#index' do
        before do
          visit admin_digital_service_accounts_path
        end

        it 'load the Services#index page' do
          expect(page).to have_content('Social Media Accounts')

          expect(page).to have_link('Back to the Digital Registry')
          expect(page).to have_link('New Account')
          #expect(page).to have_link('Export results to .csv')

          within('.usa-table') do
            expect(page).to have_content('Account type (platform)')
            expect(page).to have_content('Name (handle)')
            expect(page).to have_content('Status')
            expect(page).to have_content('Updated at')
          end
        end
      end
    end

    context 'with records' do
      let!(:organizations) { FactoryBot.create_list(:organization, 7) }
      let(:users) { FactoryBot.create_list(:user, 5, organization: organizations.sample) }
      let!(:digital_service_accounts) { FactoryBot.create_list(:digital_service_account, 10) }

      describe '#index' do
        before do
          visit admin_digital_service_accounts_path
          within('.usa-table tbody tr:first-child') do
            click_on('Service Account 1')
          end
        end

        it 'load the DigitalServiceAccount#index page' do
          expect(page).to have_content('Social Media Account')
          expect(page).to have_content('Service Account 1')
        end
      end
    end

    describe 'create' do
      before 'fill-in the form' do
        visit admin_digital_service_accounts_path
        click_on 'New Account'
        expect(page).to have_content('New Social Media Account')
        fill_in :digital_service_account_name, with: 'Test Name'
        select('Facebook', from: 'digital_service_account[account]')
        fill_in :digital_service_account_service_url, with: 'https://twitter.com/government'
        click_on 'Create social media account'
      end

      it 'creates Digital Service Account successfully' do
        expect(page).to have_content('Digital service account was successfully created')
        within('.events') do
          expect(page).to have_content('digital_service_account_created')
          expect(page).to have_content('by admin@example.gov')
          expect(page).to have_content('less than a minute ago')
        end
      end
    end

    describe 'add tag' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)

        fill_in('digital_service_account_tag_list', with: 'tag123')
        page.find('#digital_service_account_tag_list').native.send_keys :tab
      end

      it 'creates a tag' do
        expect(page).to have_content('TAG123')
        expect(page).to have_css('.usa-tag', text: 'tag123'.upcase)
      end
    end

    describe 'remove tag' do
      let(:tag_text) { 'a brand new tag' }
      let(:digital_service_account) { FactoryBot.create(:digital_service_account, tag_list: [tag_text]) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)

        find('.tag-list .remove-tag-link').click
      end

      it 'removes the tag' do
        expect(page).to_not have_content(tag_text)
      end
    end

    describe 'add organization' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)

        select(organization.name, from: 'organization_id')
        page.find('#digital_service_account_tag_list').native.send_keys :tab # to lose focus
      end

      it 'creates an organization' do
        expect(page).to have_css('.usa-tag', text: organization.name.upcase)
      end
    end

    describe 'remove organization' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before 'fill-in the form' do
        digital_service_account.organization_list.add(organization.id)
        visit admin_digital_service_account_path(digital_service_account)
        select(organization.name, from: 'organization_id')
        expect(page).to have_content(organization.name.upcase)
        find('.remove-tag-link').click
      end

      it 'removes the organization' do
        expect(page).to_not have_content(organization.name.upcase)
      end
    end

    describe 'add a valid user contact' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before do
        visit admin_digital_service_account_path(digital_service_account)

        fill_in('digital_service_account_user_email_address', with: user.email)
        page.find('#digital_service_account_user_email_address').native.send_keys :tab
      end

      it 'creates and displays the tag' do
        expect(page).to have_css('.usa-tag', text: user.email.upcase)
      end
    end

    describe 'try to add an invalid user contact' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before do
        visit admin_digital_service_account_path(digital_service_account)

        fill_in('digital_service_account_user_email_address', with: 'nonexistent-email@example.gov')
        page.find('#digital_service_account_user_email_address').native.send_keys :tab
      end

      it 'displays an error message as an alert' do
        sleep 0.3
        expect(page.driver.browser.switch_to.alert).to be_truthy
        alert_text = page.driver.browser.switch_to.alert.text
        expect(alert_text).to eq('User nonexistent-email@example.gov does not exist.')
      end
    end

    describe 'remove user contact' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }
      let!(:role) { user.add_role(:contact, digital_service_account) }

      before 'fill-in the form' do
        visit admin_digital_service_account_path(digital_service_account)
        expect(page).to have_content(user.email.upcase)
        find('.users-list .remove-tag-link').click
      end

      it 'removes the user' do
        expect(page).to_not have_content(user.email.upcase)
      end
    end

    describe '#search' do
      let!(:digital_service_account) { FactoryBot.create(:digital_service_account, name: 'Test1', service: 'facebook', aasm_state: 'published') }
      let!(:digital_service_account_2) { FactoryBot.create(:digital_service_account, aasm_state: 'created') }

      before do
        visit admin_digital_service_accounts_path
      end

      it 'can search by keyword' do
        fill_in :tags, with: digital_service_account.name
        find('#tags').native.send_key :tab
        expect(page).to have_css('tbody tr', count: 1)
      end

      it 'can search by organization' do
        digital_service_account.organization_list.add(organization.id)
        digital_service_account.save
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

    describe '#review' do
      let!(:digital_service_account) { FactoryBot.create(:digital_service_account, name: 'Test1', service: 'Facebook', aasm_state: 'published') }
      let!(:digital_service_account_2) { FactoryBot.create(:digital_service_account, aasm_state: 'created') }
      let!(:digital_service_account_3) { FactoryBot.create(:digital_service_account, aasm_state: 'updated') }

      before do
        visit review_admin_digital_service_accounts_path
      end

      it 'shows a table with 1 filtered result' do
        expect(page).to have_content('Review Social Media Accounts')
        expect(page).to have_link('New Account')
        expect(page).to have_css('.usa-table tbody tr', count: 2)
      end
    end

    describe '#delete' do
      let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

      before do
        visit admin_digital_service_account_path(digital_service_account)
      end

      it 'can delete digital service account' do
        click_on 'Edit'
        expect(page).to have_content('Editing Social Media Account')
        accept_confirm do
          click_link 'Delete'
        end
        expect(page).to have_content('Digital service account was deleted.')
      end
    end
  end

  context 'as Contact' do
    let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

    before do
      user.add_role(:contact, digital_service_account)
      login_as user
      visit admin_digital_service_account_path(digital_service_account)
    end

    it 'contact can edit digital service account' do
      click_on 'Edit'
      expect(page).to have_content('Editing Social Media Account')
    end
  end
end
