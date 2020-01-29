require 'rails_helper'

feature "Submissions", js: true do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:touchpoint) { FactoryBot.create(:touchpoint, :with_form, organization: organization)}

  context "as Admin" do
    describe "/touchpoints/:id with submissions" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      before do
        login_as admin
      end

      context "#show" do
        let!(:user_role) { FactoryBot.create(:user_role, user: admin, touchpoint: touchpoint, role: UserRole::Role::TouchpointManager) }

        describe "xss injection attempt" do
          context "when no Submissions exist" do
            before do
              FactoryBot.create(:submission, touchpoint: touchpoint, answer_01: "content_tag(&quot;/&gt;&lt;script&gt;alert(&#39;hack!&#39;);&lt;/script&gt;&quot;)")
              visit admin_touchpoint_path(touchpoint)
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
            let!(:submission) { FactoryBot.create(:submission, touchpoint: touchpoint) }

            before do
              visit admin_touchpoint_path(touchpoint)
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
            let!(:submission) { FactoryBot.create(:submission, touchpoint: touchpoint) }

            before do
              visit admin_touchpoint_path(touchpoint)
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
