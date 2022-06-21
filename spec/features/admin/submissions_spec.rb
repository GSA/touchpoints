# frozen_string_literal: true

require 'rails_helper'

feature 'Submissions', js: true do
  let(:organization) { FactoryBot.create(:organization) }

  context 'as Admin' do
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }

    describe '/forms/:id with submissions' do
      before do
        login_as admin
      end

      context '#show' do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }

        describe 'xss injection attempt' do
          context 'when no Submissions exist' do
            before do
              FactoryBot.create(:submission, form:, answer_01: 'content_tag(&quot;/&gt;&lt;script&gt;alert(&#39;hack!&#39;);&lt;/script&gt;&quot;)')
              visit responses_admin_form_path(form)
            end

            it 'does not render javascript' do
              within('table.submissions') do
                find('tbody td:first-child').hover
                expect(find('table tbody').text).to have_content('content_tag(')
                # Does not spawn an alert (which is good)
                expect { page.driver.browser.switch_to.alert.accept }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
                expect(find('table tbody').text).to_not have_content('script')
              end
            end
          end
        end

        describe 'view a Response' do
          context 'with one Response' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            describe 'click View link in responses table' do
              before do
                visit responses_admin_form_path(form)
                within('table.submissions') do
                  click_on 'View'
                end
              end

              it 'view a response' do
                expect(page).to have_content('Viewing a response')
                expect(page.current_path).to eq(admin_form_submission_path(form, submission))
              end
            end
          end
        end

        describe 'tag a Response' do
          context 'with one Response' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            describe 'click View link in responses table' do
              before do
                visit responses_admin_form_path(form)
                within('table.submissions') do
                  click_on 'View'
                end
              end

              it 'view tags' do
                expect(page).to have_content('Tags')
              end

              it 'adds a tag' do
                fill_in 'submission_tag_list', with: 'tag1'
                find('#submission_tag_list').native.send_key :tab
                expect(page).to have_content('TAG1')
              end

              it 'adds multiple tags' do
                fill_in 'submission_tag_list', with: 'tag1, tag2'
                find('#submission_tag_list').native.send_key :tab
                expect(page).to have_content('TAG1')
                expect(page).to have_content('TAG2')
              end

              it 'removes a tag' do
                fill_in 'submission_tag_list', with: 'tag1, tag2'
                find('#submission_tag_list').native.send_key :tab
                expect(page).to have_content('TAG1')
                expect(page).to have_content('TAG2')
                find_all('.remove-tag-link').first.click
                expect(page).not_to have_content('TAG1')
              end
            end
          end
        end

        describe 'view many Responses' do
          context 'with more than 1 page worth of Responses' do
            let!(:submission) { FactoryBot.create_list(:submission, 120, form:) }

            describe 'click View link in responses table' do
              before do
                visit responses_admin_form_path(form)
                within(find_all('.usa-pagination').first) do
                  click_link '2'
                end
              end

              it 'view the 2nd page of responses' do
                expect(page).to have_content('Displaying Responses 101 - 120 of 120')
              end
            end
          end
        end

        describe 'can view archived Responses' do
          context 'with more than 1 page worth of Responses' do
            let!(:submissions) { FactoryBot.create_list(:submission, 45, form:) }
            let!(:archived_submissions) { FactoryBot.create_list(:submission, 70, archived: true, form:) }

            describe 'click View link in responses table' do
              before do
                visit responses_admin_form_path(form, archived: 1)
                within(find_all('.usa-pagination').first) do
                  click_link '2'
                end
              end

              it 'view the 2nd page of responses' do
                expect(page).to have_content('Displaying Responses 101 - 115 of 115')
              end
            end
          end
        end

        describe 'archive a Submission' do
          context 'with one Submission' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before 'click on Archive' do
              visit responses_admin_form_path(form)
              within('table.submissions') do
                click_on 'Archive'
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "remove the Archived submission's table row" do
              within('table.submissions') do
                expect(page).to_not have_content(submission.answer_01)
                expect(find_all('tbody tr').size).to eq(0)
              end
            end
          end
        end

        describe 'flag a Submission' do
          context 'with one Submission' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before do
              visit responses_admin_form_path(form)
              within('table.submissions') do
                click_on 'Flag'
              end
              page.driver.browser.switch_to.alert.accept
            end

            it 'successfully flags Submission' do
              within('table.submissions') do
                expect(page).to have_content('Flagged')
              end
            end
          end
        end

        describe '/feed' do
          context 'with one Submission' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before do
              visit admin_feed_path
            end

            it 'prevent access and redirect to index page' do
              expect(page).to have_content('Touchpoints Question Response Feed')
              expect(page).to have_content('Download CSV')
            end
          end
        end

        describe '/export_feed.csv?days_limit=3' do
          let!(:submission) { FactoryBot.create(:submission, form:) }

          context 'with one Submission' do
            before do
              visit admin_feed_path
              visit admin_export_feed_path(format: :csv, days_limit: 3)
            end

            it 'downloads the .csv and stays on page' do
              expect(page).to have_content('Touchpoints Question Response Feed')
            end
          end
        end
      end
    end
  end

  context 'as Form Manager' do
    describe '/forms/:id with submissions' do
      let!(:form_manager) { FactoryBot.create(:user, organization:) }
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: form_manager) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form:) }

      before do
        login_as form_manager
      end

      context '#show' do
        describe 'flag a Submission' do
          context 'with one Submission' do
            let!(:submission) { FactoryBot.create(:submission, form:) }

            before do
              visit responses_admin_form_path(form)
              within('table.submissions') do
                click_on 'Flag'
              end
              page.driver.browser.switch_to.alert.accept
            end

            it 'successfully flags Submission' do
              within('table.submissions') do
                expect(page).to have_content('Flagged')
              end
            end
          end
        end

        describe 'delete a Submission' do
          context 'with one Submission' do
            let!(:submission) { FactoryBot.create(:submission, form:) }
            let!(:submission2) { FactoryBot.create(:submission, form:) }

            before do
              visit admin_form_submission_path(form, submission)
              click_on 'Delete this response'
              page.driver.browser.switch_to.alert.accept
            end

            it 'successfully deletes a Submission' do
              expect(page).to have_content('Viewing Responses for')
              expect(page.current_path).to eq(responses_admin_form_path(form))
              expect(page.find_all('#submissions_table table tbody tr').size).to eq(1)
            end
          end
        end

        # This is a common test. not specific to just the Form Manager
        context 'for a form with a text_display element' do
          context 'with one Submission' do
            let(:form_with_text_display) { FactoryBot.create(:form, :kitchen_sink, organization:, user: form_manager) }
            let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: form_with_text_display) }
            let!(:submission) { FactoryBot.create(:submission, form: form_with_text_display) }

            before do
              visit responses_admin_form_path(form_with_text_display)
            end

            it 'does not display text_display question title' do
              within '.responses .table-scroll' do
                expect(page).to have_content('An input field')
                expect(page).to_not have_content('Some custom')
                expect(page).to_not have_content('<a>')
                expect(page).to_not have_content('</a>')
                expect(page).to have_content('A textarea field')

                expect(page).to have_link('View')
                expect(page).to have_link('Flag')
                expect(page).to have_link('Archive')
                expect(page).to have_content('Status')
                expect(page).to have_content('received')
                expect(page).to have_content('Created At')
              end
            end
          end
        end
      end

      describe '/feed' do
        context 'with one Submission' do
          before do
            visit admin_feed_path
          end

          it 'prevent access and redirect to index page' do
            expect(page).to have_content('Authorization is Required')
            expect(page.current_path).to eq(admin_root_path)
          end
        end
      end

      describe '/export_feed' do
        context 'with one Submission' do
          before do
            visit admin_export_feed_path
          end

          it 'prevent access and redirect to index page' do
            expect(page).to have_content('Authorization is Required')
            expect(page.current_path).to eq(admin_root_path)
          end
        end
      end
    end
  end

  context 'as Response Viewer' do
    describe '/forms/:id with submissions' do
      let(:response_viewer) { FactoryBot.create(:user, organization:) }
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: response_viewer) }
      let!(:user_role) { FactoryBot.create(:user_role, :response_viewer, user: response_viewer, form:) }

      before do
        login_as response_viewer
      end

      context '#show' do
        let!(:submission) { FactoryBot.create(:submission, form:) }
        let!(:submission2) { FactoryBot.create(:submission, form:, answer_01: 'superlongtext ' * 500) }

        before do
          visit responses_admin_form_path(form)
        end

        describe 'truncate text in the table displayed' do
          context 'ui_truncate_text_responses is ON' do
            it 'is on by default' do
              expect(page).to have_css('#button-toggle-table-display-options', visible: true)
              expect(page).to have_css('#table-display-options', visible: false)

              find('#button-toggle-table-display-options').click # to open option settings
              expect(page).to have_css('#table-display-options', visible: true)

              # Inspects the hidden checkbox to ensure it is checked
              expect(find('#form_ui_truncate_text_responses', visible: false).checked?).to eq true
            end

            it 'truncates text longer than 160 characters to 160 characters' do
              expect(page).to have_content('superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext sup...')

              expect(page).to_not have_content('superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext super')
            end

            it 'toggle this setting from on to off' do
              find('#button-toggle-table-display-options').click
              find('.usa-checkbox label').click
              expect(find('#form_ui_truncate_text_responses', visible: false).checked?).to eq false
              click_on 'Update options'

              # this will be true when the page reloads
              expect(page).to have_css('#table-display-options', visible: false)

              # reload the page
              visit responses_admin_form_path(form)
              form.reload
              expect(form.ui_truncate_text_responses).to eq false
              expect(find('#form_ui_truncate_text_responses', visible: false).checked?).to eq false

              expect(page).to have_content('superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext super')
            end
          end

          context 'ui_truncate_text_responses is OFF' do
            before do
              form.update(ui_truncate_text_responses: false)
              visit responses_admin_form_path(form)
            end

            it 'display text longer than 160 characters' do
              visit responses_admin_form_path(form)
              find('#button-toggle-table-display-options').click
              expect(find('#form_ui_truncate_text_responses', visible: false).checked?).to eq false

              expect(page).to have_content('superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext superlongtext super')
            end
          end
        end

        describe 'view a Submission' do
          context 'with at least one Response' do
            before do
              within('table.submissions tbody tr:first-child') do
                click_on 'View'
              end
            end

            it 'can view a Submission' do
              expect(page).to have_content('Viewing a response')
              expect(page).to_not have_content('Delete')
            end
          end
        end

        describe 'flag a Submission' do
          context 'with one Response' do
            before do
              within('table.submissions tbody tr:first-child') do
                click_on 'Flag'
              end
              page.driver.browser.switch_to.alert.accept
            end

            it 'successfully flags Submission' do
              within('table.submissions tbody tr:first-child') do
                expect(page).to have_content('Flagged')
              end
            end
          end
        end

        context 'with one Response' do
          describe 'row-level response buttons ' do
            it 'do not show Delete button' do
              within('table.submissions') do
                expect(page).to_not have_content('Delete')
              end
            end
          end
        end
      end
    end
  end

  context 'non-privileged User' do
    let(:admin) { FactoryBot.create(:user, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
    let(:user) { FactoryBot.create(:user, organization:) }

    context "with an existing Form that the user doesn't have permissions to" do
      describe '/forms/:id with submissions' do
        before do
          login_as user
        end

        context '#show' do
          before do
            visit admin_form_path(form)
          end

          it 'prevent access and redirect to admin index page' do
            expect(page).to have_content('Authorization is Required')
            expect(page.current_path).to eq(admin_root_path)
          end
        end
      end
    end
  end

  context 'logged out user' do
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }
    let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form:) }
    let!(:submission) { FactoryBot.create(:submission, form:) }

    describe '/forms/:id with submissions' do
      context 'with one Submission' do
        before do
          visit admin_form_path(form)
        end

        it 'prevent access and redirect to index page' do
          expect(page).to have_content('Authorization is Required')
          expect(page.current_path).to eq(index_path)
        end
      end
    end
  end
end
