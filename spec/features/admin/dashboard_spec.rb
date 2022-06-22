# frozen_string_literal: true

require 'rails_helper'

feature 'Admin Dashboard', js: true do
  describe 'Admin' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }

    before do
      login_as admin
      visit admin_dashboard_path
    end

    it 'display admin links' do
      expect(page).to have_link('Organizations')
      expect(page).to have_link('Users')
      expect(page).to have_link('Manage Sidekiq')
    end

    describe 'weekly metrics' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
      let!(:form_template) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin, template: true) }

      before do
        visit admin_dashboard_path
      end

      it 'display weekly metrics' do
        expect(page).to have_content('Weekly Product Metrics')
        expect(page).to have_content('Users')
        expect(page).to have_content('Agencies')
        expect(page).to have_content('Forms')
        expect(page).to have_content('Responses')
        expect(page).to have_content('Services')
        expect(page).to have_content('Websites')
        expect(page).to have_content('Data Collections')
        expect(page).to have_content('Service details')
        expect(find('.reportable-users')).to have_content('1')
        expect(find('.reportable-organizations')).to have_content('1')
        expect(find('.reportable-forms')).to have_content('1')
        expect(find('.reportable-submissions')).to have_content('0')
      end
    end

    describe 'agency summary' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
      let!(:form2) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
      let!(:form_template) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin, template: true) }

      before do
        form2.archive!
        visit admin_management_path
      end

      it 'display agency summary' do
        expect(page).to have_content('Agency Summary')
        expect(page).to have_content('Agency')
        expect(page).to have_content('All Forms')
        expect(page).to have_content('Active Forms')
        within(".agency_tr#{organization.id}") do
          expect(find('.reportable-agencies')).to have_content(organization.name)
          expect(find('.reportable-total-forms')).to have_content('2')
          expect(find('.reportable-active-forms')).to have_content('1')
        end
      end
    end

    describe 'daily totals' do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
      let!(:form_template) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin, template: true) }

      before do
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 10.days.ago,
                          })
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 5.days.ago,
                          })
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 5.days.ago,
                          })
        User.create({
                      email: 'tester1@example.com',
                      created_at: 10.days.ago,
                    })
        User.create({
                      email: 'tester2@example.com',
                      created_at: 5.days.ago,
                    })
        User.create({
                      email: 'tester3@example.com',
                      created_at: 5.days.ago,
                    })
        visit admin_dashboard_path
      end

      it 'display weekly metrics' do
        expect(page).to have_css('#daily-responses')
        expect(page).to have_css('#daily-new-users')
        expect(find_all('canvas').size).to eq(2)
      end
    end

    describe '#a11' do
      let!(:form) { FactoryBot.create(:form, kind: 'a11', organization:, user: admin) }

      before do
        visit admin_a11_path
      end

      it 'display Customer Feedback Analysis' do
        expect(page).to have_css('#customer-feedback-summary')
        within '#customer-feedback-summary' do
          expect(find_all('tbody tr').size).to eq(1)
          expect(page).to have_content form.organization.name
          expect(page).to have_content form.name
        end
      end
    end

    describe '#lifespan' do
      let!(:form) { FactoryBot.create(:form, kind: 'a11', organization:, user: admin) }

      before do
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 10.days.ago,
                          })
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 5.days.ago,
                          })
        Submission.create({
                            form_id: form.id,
                            answer_01: 'yes',
                            created_at: 5.days.ago,
                          })
        visit admin_lifespan_path
      end

      it 'displays Agency lifespan summary' do
        expect(page).to have_content('Survey Lifespan by Agency')
        within '.agency-survey-lifespan-rerport' do
          expect(page).to have_content form.organization.name
          expect(page).to have_content form.name
        end
      end
    end
  end

  # Note:
  # Public users do not log in.
  # Logged in users are .gov users, but have no default permissions
  describe 'non-privileged User' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as user
      visit admin_dashboard_path
    end

    it 'does not have admin links' do
      expect(page).to_not have_link('Manage Organizations')
      expect(page).to_not have_link('Manage Form Templates')
    end

    it 'has instructional text' do
      expect(page).to have_content('Create a Form')
      expect(page).to have_content('Customize the Form with Questions and Question Options')
      expect(page).to have_content('Test the Form by creating a Response')
      expect(page).to have_content('Deploy the Form to Users on your website or via your email system')
      expect(page).to have_content('Receive feedback from Users')
      expect(page).to have_content('Use the feedback to improve service delivery')
    end
  end

  describe 'non logged-in User' do
    before do
      visit admin_root_path
    end

    it 'redirected to home page and sees flash message' do
      expect(page.current_path).to eq(index_path)
      expect(page).to have_content('Authorization is Required')
    end
  end
end
