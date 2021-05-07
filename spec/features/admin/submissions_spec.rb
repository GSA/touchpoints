require 'rails_helper'

feature "Submissions", js: true do
  let(:organization) { FactoryBot.create(:organization) }

  context "as Admin" do
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin) }

    describe "/forms/:id with submissions" do
      before do
        login_as admin
      end

      context "#show" do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }

        describe "xss injection attempt" do
          context "when no Submissions exist" do
            before do
              FactoryBot.create(:submission, form: form, answer_01: "content_tag(&quot;/&gt;&lt;script&gt;alert(&#39;hack!&#39;);&lt;/script&gt;&quot;)")
              visit responses_admin_form_path(form)
            end

            it "does not render javascript" do
              within("table.submissions") do
                find('tbody td:first-child').hover
                expect(find('table tbody').text).to have_content("content_tag(")
                # Does not spawn an alert (which is good)
                expect { page.driver.browser.switch_to.alert.accept }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
                expect(find('table tbody').text).to_not have_content("script")
              end
            end
          end
        end

        describe "view a Response" do
          context "with one Response" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }

            before do
              visit responses_admin_form_path(form)
              within("table.submissions") do
                click_on "View"
              end
            end

            it "view a response" do
              expect(page).to have_content("Viewing a response")
            end
          end
        end

        describe "flag a Submission" do
          context "with one Submission" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }

            before do
              visit responses_admin_form_path(form)
              within("table.submissions") do
                click_on "Flag"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully flags Submission" do
              within("table.submissions") do
                expect(page).to have_content("Flagged")
              end
            end
          end
        end

        describe "delete a Submission" do
          context "with one Submission" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }
            let!(:submission2) { FactoryBot.create(:submission, form: form, answer_01: "Unique Text askldfjsadkl;fsda") }

            before do
              visit responses_admin_form_path(form)
              expect(page).to have_css(".responses table tbody tr")
              expect(page.find_all(".responses table tbody tr").size).to eq(2)
              within("table.submissions") do
                first("tr.response").click_on "Delete" # latest response
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully deletes a Submission" do
              expect(page).to have_content(submission.answer_01)
              expect(page).to_not have_content(submission2.answer_01)
              expect(page.find_all(".responses table tbody tr").size).to eq(1)
            end
          end
        end
      end

    end
  end

  context "as Form Manager" do
    describe "/forms/:id with submissions" do
      let!(:form_manager) { FactoryBot.create(:user, organization: organization) }
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: form_manager) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: form) }

      before do
        login_as form_manager
      end

      context "#show" do
        describe "flag a Submission" do
          context "with one Submission" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }

            before do
              visit responses_admin_form_path(form)
              within("table.submissions") do
                click_on "Flag"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully flags Submission" do
              within("table.submissions") do
                expect(page).to have_content("Flagged")
              end
            end
          end
        end

        describe "delete a Submission" do
          context "with one Submission" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }

            before do
              visit responses_admin_form_path(form)
              expect(page).to have_css(".responses table tbody tr")
              within("table.submissions") do
                click_on "Delete"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully deletes a Submission" do
              expect(page).to_not have_css(".responses table tbody tr")
            end
          end
        end

        # This is a common test. not specific to just the Form Manager
        context "for a form with a text_display element" do
          context "with one Submission" do
            let(:form_with_text_display) { FactoryBot.create(:form, :kitchen_sink, organization: organization, user: form_manager) }
            let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: form_manager, form: form_with_text_display) }
            let!(:submission) { FactoryBot.create(:submission, form: form_with_text_display) }

            before do
              visit responses_admin_form_path(form_with_text_display)
            end

            it "does not display text_display question title" do
              within ".responses .table-scroll" do
                expect(page).to have_content("An input field")
                expect(page).to_not have_content("Some custom")
                expect(page).to_not have_content("<a>")
                expect(page).to_not have_content("</a>")
                expect(page).to have_content("A textarea field")
                expect(page).to have_content("Created At")
                expect(page).to have_link("Flag")
                expect(page).to have_link("Delete")
              end
            end
          end
        end
      end

    end
  end

  context "as Response Viewer" do
    describe "/forms/:id with submissions" do
      let(:response_viewer) { FactoryBot.create(:user, organization: organization) }
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: response_viewer) }
      let!(:user_role) { FactoryBot.create(:user_role, :response_viewer, user: response_viewer, form: form) }

      before do
        login_as response_viewer
      end

      context "#show" do
        let!(:submission) { FactoryBot.create(:submission, form: form) }

        before do
          visit responses_admin_form_path(form)
        end

        describe "flag a Submission" do
          context "with one Response" do
            before do
              within("table.submissions") do
                click_on "Flag"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully flags Submission" do
              within("table.submissions") do
                expect(page).to have_content("Flagged")
              end
            end
          end
        end

        context "with one Response" do
          describe "row-level response buttons " do
            it "do not show Delete button" do
              within("table.submissions") do
                expect(page).to_not have_content("Delete")
              end
            end
          end
        end
      end

    end
  end

  context "non-privileged User" do
    let(:admin) { FactoryBot.create(:user, organization: organization) }
    let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin) }
    let(:user) { FactoryBot.create(:user, organization: organization) }

    context "with an existing Form that the user doesn't have permissions to" do
      describe "/forms/:id with submissions" do
        before do
          login_as user
        end

        context "#show" do
          before do
            visit admin_form_path(form)
          end

          it "prevent access and redirect to admin index page" do
            expect(page).to have_content("Authorization is Required")
            expect(page.current_path).to eq(admin_root_path)
          end
        end
      end
    end
  end

  context "logged out user" do
    describe "/forms/:id with submissions" do
      let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin) }
      let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }
      let!(:submission) { FactoryBot.create(:submission, form: form) }

      context "with one Submission" do
        before do
          visit admin_form_path(form)
        end

        it "prevent access and redirect to index page" do
          expect(page).to have_content("Authorization is Required")
          expect(page.current_path).to eq(index_path)
        end
      end
    end
  end

end
