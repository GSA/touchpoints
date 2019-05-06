require 'rails_helper'

feature "Touchpoints", js: true do
  context "as Admin" do
    describe "/touchpoints" do
      context "#index" do
        let(:user) { FactoryBot.create(:user, :admin) }
        let!(:service) { FactoryBot.create(:service) }
        let!(:user_service) { FactoryBot.create(:user_service, user: user, service: service, role: UserService::Role::ServiceManager) }
        let!(:form) { FactoryBot.create(:form) }
        let(:future_date) {
          Time.now + 3.days
        }

        before "user creates a Touchpoint" do
          login_as user
          visit new_admin_touchpoint_path
          fill_in("touchpoint[name]", with: "Test Touchpoint")
          select(service.name, from: "touchpoint[service_id]")

          # FIXME
          # this is non-conventional, because USWDS hides inputs and uses CSS :before
          first("label[for=touchpoint_form_id_1]").click
          fill_in("touchpoint[purpose]", with: "Compliance")
          fill_in("touchpoint[expiration_date]", with: future_date.strftime("%m/%d/%Y"))
          fill_in("touchpoint[omb_approval_number]", with: "12345")
          fill_in("touchpoint[meaningful_response_size]", with: 50)
          fill_in("touchpoint[behavior_change]", with: "to be determined")
          fill_in("touchpoint[notification_emails]", with: "admin@example.gov")
          click_button "Create Touchpoint"
        end

        it "redirect to /touchpoints/:id with a success flash message" do
          expect(page.current_path).to eq(admin_touchpoint_path(Touchpoint.first.id))
          expect(page).to have_content("Touchpoint was successfully created.")
          expect(page).to have_content(future_date.to_date.to_s)
          expect(page).to have_content("Notification emails: admin@example.gov")
          expect(page).to have_content("12345")
        end
      end

      context "#edit" do
        let(:user) { FactoryBot.create(:user, :admin) }
        let!(:organization) { FactoryBot.create(:organization) }
        let!(:touchpoint) { FactoryBot.create(:touchpoint)}
        let!(:form) { FactoryBot.create(:form) }
        let(:new_name) { "New Name" }

        describe "user updates a Touchpoint" do
          before do
            login_as user
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
        let(:admin) { FactoryBot.create(:user, :admin) }
        let!(:organization) { FactoryBot.create(:organization) }
        let(:touchpoint) { FactoryBot.create(:touchpoint)}

        describe "Submission Export button" do
          context "when no Submissions exist" do
            before do
              login_as admin
              visit admin_touchpoint_path(touchpoint.id)
            end

            it "display No Submissions message" do
              expect(page).to have_content("Export is not available. This Touchpoint has yet to receive any Submissions.")
            end
          end

          context "when Submissions exist" do
            let!(:submission) { FactoryBot.create(:submission, touchpoint: touchpoint)}

            before do
              login_as admin
              visit admin_touchpoint_path(touchpoint.id)
            end

            it "display table list of Submissions and Export button link" do
              within("table") do
                expect(page).to have_content(submission.body)
              end
              expect(page).to have_link("Export Submissions to Google Sheet")
            end
          end

        end
      end
    end
  end

  context "as Webmaster" do
    describe "/touchpoints" do
      describe "#index" do
        let(:service) { FactoryBot.create(:service) }
        let(:user) { FactoryBot.create(:user, :admin, organization: service.organization) }
        let!(:user_service) { FactoryBot.create(:user_service, user: user, service: service, role: UserService::Role::ServiceManager) }
        let!(:form) { FactoryBot.create(:form) }

        before "user completes (TEST) Sign Up form" do
          login_as user
          visit new_admin_touchpoint_path

          fill_in("touchpoint[name]", with: "Test Touchpoint")
          fill_in("touchpoint[omb_approval_number]", with: 1234)
          # FIXME
          # this is non-conventional, because USWDS hides inputs and uses CSS :before
          first("label[for=touchpoint_form_id_1]").click
          select(service.name, from: "touchpoint[service_id]")
          fill_in("touchpoint[meaningful_response_size]", with: 50)
          fill_in("touchpoint[notification_emails]", with: "admin@example.gov")
          fill_in("touchpoint[purpose]", with: "Compliance")
          fill_in("touchpoint[behavior_change]", with: "to be determined")
          click_button "Create Touchpoint"
        end

        it "redirect to /touchpoints/:id with a success flash message" do
          expect(page).to have_content("Touchpoint was successfully created.")
          @touchpoint = Touchpoint.first
          expect(page.current_path).to eq(admin_touchpoint_path(@touchpoint.id))
          expect(page).to have_content("Test Touchpoint")
          expect(page).to have_content(@touchpoint.service.name)
          expect(page).to have_content("1234")
          expect(page).to have_content("50")
          expect(page).to have_content("1234")
          expect(page).to have_content("Compliance")
          expect(page).to have_content(@touchpoint.form.name)
          expect(page).to have_content("to be determined")
          expect(page).to have_content("Notification emails: admin@example.gov")
        end
      end
    end
  end
end
