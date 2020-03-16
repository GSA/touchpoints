require 'rails_helper'

feature "Submissions", js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin) }

  context "as Admin" do
    describe "/forms/:id with submissions" do
      before do
        login_as admin
      end

      context "#show" do
        let!(:user_role) { FactoryBot.create(:user_role, :form_manager, user: admin, form: form) }
        # let!(:user_role) { FactoryBot.create(:user_role, user: admin, form: form, role: UserRole::Role::FormManager) }

        describe "xss injection attempt" do
          context "when no Submissions exist" do
            before do
              FactoryBot.create(:submission, form: form, answer_01: "content_tag(&quot;/&gt;&lt;script&gt;alert(&#39;hack!&#39;);&lt;/script&gt;&quot;)")
              visit admin_form_path(form)
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

        describe "flag a Submission" do
          context "with one Submission" do
            let!(:submission) { FactoryBot.create(:submission, form: form) }

            before do
              visit admin_form_path(form)
              within("table.submissions") do
                click_on "Flag"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully flags Submission" do
              expect(page).to have_content("Response #{submission.id} was successfully flagged.")
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
              visit admin_form_path(form)
              within("table.submissions") do
                click_on "Delete"
              end
              page.driver.browser.switch_to.alert.accept
            end

            it "successfully deletes a Submission" do
              expect(page).to have_content("Response #{submission.id} was successfully destroyed.")
            end
          end
        end
      end
    end
  end
end
