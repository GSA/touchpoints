require 'rails_helper'

feature "Touchpoints", js: true do
  let!(:organization) { FactoryBot.create(:organization) }
  let!(:touchpoint) { FactoryBot.create(:touchpoint, :with_form, organization: organization)}
  let(:future_date) {
    Time.now + 3.days
  }

  context "as Admin" do
    describe "/touchpoints" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      before do
        login_as admin
      end

      context "#index" do
        let!(:user_role) { FactoryBot.create(:user_role, user: admin, touchpoint: touchpoint, role: UserRole::Role::TouchpointManager) }
        let!(:form_template) { FactoryBot.create(:form_template) }

        before "user creates a Touchpoint" do
          visit new_admin_touchpoint_path
          fill_in("touchpoint[name]", with: "Test Touchpoint")
          fill_in("touchpoint[purpose]", with: "Compliance")
          fill_in("touchpoint[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
          fill_in("touchpoint[omb_approval_number]", with: "12345")
          fill_in("touchpoint[meaningful_response_size]", with: 50)
          fill_in("touchpoint[behavior_change]", with: "to be determined")
          fill_in("touchpoint[notification_emails]", with: "admin@example.gov")
          click_button "Create Touchpoint"
        end

        it "redirect to /touchpoints/:id with a success flash message" do
          expect(page.current_path).to eq(admin_touchpoint_path(Touchpoint.last.id))
          expect(page).to have_content("Touchpoint was successfully created.")
          expect(page).to have_content(future_date.to_date.to_s)
          expect(page).to have_content("Notification emails: admin@example.gov")
          expect(page).to have_content("12345")
        end
      end

      context "#edit" do
        let!(:organization) { FactoryBot.create(:organization) }
        let!(:form_template) { FactoryBot.create(:form_template) }
        let(:new_name) { "New Name" }

        describe "user updates a Touchpoint" do
          before do
            visit edit_admin_touchpoint_path(touchpoint.id)
            fill_in("touchpoint[name]", with: new_name)
            click_button "Update Touchpoint"
          end

          it "redirect to /touchpoints/:id with a success flash message" do
            expect(page.current_path).to eq(admin_touchpoint_path(touchpoint.id))
            expect(page).to have_content("Touchpoint was successfully updated.")
            expect(page).to have_content(new_name)
          end
        end
      end

      context "#show" do
        let!(:user_role) { FactoryBot.create(:user_role, user: admin, touchpoint: touchpoint, role: UserRole::Role::TouchpointManager) }

        describe "Submission Export button" do
          context "when no Submissions exist" do
            before do
              visit admin_touchpoint_path(touchpoint.id)
            end

            it "display No Submissions message" do
              expect(page).to have_content("Export is not available. This Touchpoint has yet to receive any Submissions.")
            end
          end

          context "when Submissions exist" do
            let!(:submission) { FactoryBot.create(:submission, touchpoint: touchpoint)}

            before do
              visit admin_touchpoint_path(touchpoint.id)
            end

            it "display table list of Submissions and Export CSV button link" do
              within("table.submissions") do
                expect(page).to have_content(submission.answer_01)
              end
              expect(page).to have_link("Export Submissions to CSV")
            end
          end

        end
      end

      context "#example" do
        describe "Touchpoint with `inline` delivery_method" do
          let(:inline_touchpoint) { FactoryBot.create(:touchpoint, :inline, :with_form) }

          before "/admin/touchpoints/:id/example" do
            visit example_admin_touchpoint_path(inline_touchpoint.id)
          end

          it "can complete then submit the inline Form and see a Success message" do
            fill_in "answer_01", with: "We the People of the United States, in Order to form a more perfect Union..."
            click_on "Submit"
            expect(page).to have_content("Success")
            expect(page).to have_content("Thank you. Your feedback has been received.")
          end
        end
      end
    end
  end

  context "as Organization Manager" do
    let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }

    before do
      login_as organization_manager
    end

    describe "/touchpoints" do
      describe "#new" do
        let!(:form_template) { FactoryBot.create(:form_template) }

        before "User can create a Touchpoint" do
          visit new_admin_touchpoint_path

          fill_in("touchpoint[name]", with: "Test Touchpoint")
          fill_in("touchpoint[omb_approval_number]", with: 1234)
          fill_in("touchpoint[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
          fill_in("touchpoint[meaningful_response_size]", with: 50)
          fill_in("touchpoint[notification_emails]", with: "admin@example.gov")
          fill_in("touchpoint[purpose]", with: "Compliance")
          fill_in("touchpoint[behavior_change]", with: "to be determined")
          click_button "Create Touchpoint"
        end

        it "redirect to /touchpoints/:id with a success flash message" do
          expect(page).to have_content("Touchpoint was successfully created.")
          @touchpoint = Touchpoint.last
          expect(page.current_path).to eq(admin_touchpoint_path(@touchpoint.id))
          expect(page).to have_content("Test Touchpoint")
          expect(page).to have_content("1234")
          expect(page).to have_content("50")
          expect(page).to have_content("1234")
          expect(page).to have_content("Compliance")
          expect(page).to have_content("to be determined")
          expect(page).to have_content("Notification emails: admin@example.gov")
        end

        describe "Touchpoint data validations" do
          describe "missing OMB Approval Number" do
            before "user tries to create a Touchpoint" do
              visit new_admin_touchpoint_path

              fill_in("touchpoint[name]", with: "Test Touchpoint")
              fill_in("touchpoint[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
              click_button "Create Touchpoint"
            end

            it "display a flash message about missing OMB Approval Number" do
              within(".usa-alert--error") do
                expect(page).to have_content("Omb approval number required with an Expiration Date")
              end
            end
          end

          describe "missing Expiration Date" do
            before "user tries to create a Touchpoint" do
              visit new_admin_touchpoint_path

              fill_in("touchpoint[name]", with: "Test Touchpoint")
              fill_in("touchpoint[omb_approval_number]", with: 1234)
              click_button "Create Touchpoint"
            end

            it "display a flash message about missing Expiration Date" do
              within(".usa-alert--error") do
                expect(page).to have_content("Expiration date required with an OMB Number")
              end
            end
          end
        end
      end
    end
  end
end
