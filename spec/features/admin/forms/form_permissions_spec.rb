# frozen_string_literal: true

require 'rails_helper'

feature 'Forms', js: true do
  let(:future_date) do
    3.days.from_now
  end
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let!(:form) { FactoryBot.create(:form, organization:, user: admin) }
  let!(:user) { FactoryBot.create(:user, organization:) }

  context 'as Admin' do
    before do
      login_as(admin)
    end

    describe '/admin/forms/:id/permissions' do
      context 'normal scenario' do
        before do
          visit permissions_admin_form_path(form)
        end

        describe 'add a user' do
          before do
            expect(page).to have_content('No users at this time')
            select(user.email, from: 'add-user-id')
            select('Form Manager', from: 'add-user-role')
            click_on 'Add User'
          end

          it 'can preview a form' do
            expect(page).to_not have_content('No users at this time')

            within(".roles-and-permissions table tr[data-user-id=\"#{user.id}\"]") do
              expect(page).to have_content(user.email)
              expect(page).to have_link('Delete')
            end
          end
        end
      end

      context 'with a permission added in another session' do
        before do
          visit permissions_admin_form_path(form)
          # Then create a UserRole, as if somebody else did this in another session
          UserRole.create!(user_id: user.id, form_id: form.id, role: UserRole::Role::FormManager)
        end

        describe 'trying to add a user that has already been added' do
          before do
            expect(page).to have_content('No users at this time')
            select(user.email, from: 'add-user-id')
            select('Form Manager', from: 'add-user-role')
            click_on 'Add User'
            sleep 0.3
          end

          it 'can preview a form' do
            expect(page.driver.browser.switch_to.alert).to be_truthy
            alert_text = page.driver.browser.switch_to.alert.text
            expect(alert_text).to eq('This User Role could not be added.')
          end
        end
      end
    end
  end
end
