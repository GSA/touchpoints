require 'rails_helper'

feature "Managing Services", js: true do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:service) { FactoryBot.create(:service, organization: admin.organization) }
  let!(:user_service) { FactoryBot.create(:user_service, user: admin, service: service, role: UserService::Role::ServiceManager) }

  let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }
  let(:organization_managers_service) { FactoryBot.create(:service, organization: organization_manager.organization) }
  let!(:user_service2) { FactoryBot.create(:user_service, user: organization_manager, service: organization_managers_service, role: UserService::Role::ServiceManager) }

  context "as Admin" do
    before "user creates a Touchpoint" do
      login_as admin
      visit admin_services_path
    end

    it "display Admin-specific UI content" do
      expect(page).to have_content("Organization")
    end
  end

  context "as Organization Manager" do
    before "Sign in" do
      login_as organization_manager
      visit admin_services_path
    end

    it "display only the Services that belong to Webmaster" do
      expect(page).to have_content("Services")
      expect(page).to have_link("New Service")
      expect(page).to have_content(organization_managers_service.name)
      expect(page).to_not have_content(service.name)
      expect(page.current_path).to eq("/admin/services")
    end

    context "at /admin/services" do
      before "click New Service button" do
        click_link "New Service"
      end

      it "arrive at /admin/services/new" do
        expect(page).to have_content("New Service")
        expect(page).to have_content("Additional Service Managers can be assigned after creating this Service.")
        expect(page).to have_button("Create Service")
        expect(page.current_path).to eq("/admin/services/new")
      end

      describe "#new" do
        describe "unsuccessfully create Service" do
          before do
            @service = FactoryBot.build(:service)
            fill_in "service_name", with: nil # no name
            fill_in "service_description", with: @service.description
            click_button "Create Service"
          end

          it "display error alert message" do
            expect(page).to have_content("1 error prohibited this service from being saved:")
            expect(page).to have_content("Name can't be blank")
            expect(page).to have_content("New Service")
            expect(page).to have_content(@service.description)
          end
        end

        describe "successfully create a Service" do
          before do
            @service = FactoryBot.build(:service)
            fill_in "service_name", with: @service.name
            fill_in "service_description", with: @service.description
            click_button "Create Service"
          end

          it "create Service successfully" do
            expect(page).to have_content("Service was successfully created.")
            expect(page).to have_content(@service.name)
            expect(page).to have_content(@service.description)
          end
        end
      end
    end

    describe "Managing Users for a Service" do
      describe "add Service Manager to Service" do
        before "select User, click Service Manager" do
          visit admin_service_path(organization_managers_service)
          select(admin.email, from: "add-user-dropdown")
          click_on "Add Service Manager"
        end

        it "successfully add Admin as a Service Manager" do
          expect(page).to have_content("User successfully added")
          expect(page).to have_content(organization_manager.email)
          expect(page).to have_content(admin.email)
        end

        describe "When all Users are selected" do
          it "display no more users to add message" do
            expect(page).to have_content("All Users have been added. No Service Managers to add.")
            expect(page).to have_content("All Users have been added. No Submission Viewers to add.")
          end
        end

        describe "limit dropdown to Service Managers from same Organization" do
          let!(:other_org) { FactoryBot.create(:organization, domain: "other.gov") }
          let!(:user_from_other_org) { FactoryBot.create(:user, organization: other_org, email: "user@#{other_org.domain}") }
          let!(:extra_user_from_same_org) { FactoryBot.create(:user, organization: admin.organization, email: "colleague@#{admin.organization.domain}") }

          it "display Users from same Organization" do
            expect(page).to have_content(extra_user_from_same_org.email)
          end

          it "do not display Users from other Organizations" do
            expect(page).to_not have_content(user_from_other_org.email)
          end
        end

      end

      describe "remove Service Manager from Service" do
        before "for a listed User, click Remove" do
          FactoryBot.create(:user_service, user: admin, service: organization_managers_service, role: UserService::Role::ServiceManager)
          visit admin_service_path(organization_managers_service)
          within("table") do
            click_link("Remove")
          end
        end

        it "successfully remove User as a Service Manager" do
          expect(page).to have_content("User successfully removed")
          within("table") do
            expect(page).to have_content(organization_manager.email)
            expect(page).to_not have_content(admin.email)
          end
          expect(page).to have_content("Add a User?")
          expect(page).to have_css("#add-user-button[disabled]")
        end
      end
    end
  end

  context "as Webmaster" do
    let(:webmaster) { FactoryBot.create(:user) }
    let!(:webmaster_user_service) { FactoryBot.create(:user_service, user: webmaster, service: organization_managers_service, role: UserService::Role::ServiceManager) }

    before "Sign in" do
      login_as webmaster
      visit admin_services_path
    end

    it "display only the Services that belong to Webmaster" do
      expect(page).to have_content("Services")
      expect(page).to_not have_link("New Service")
    end

    describe "Managing Users for a Service" do
      describe "add Service Manager to Service" do
        before "select User, click Service Manager" do
          visit admin_service_path(organization_managers_service)
          select(admin.email, from: "add-user-dropdown")
          click_on "Add Service Manager"
        end

        it "successfully add Admin as a Service Manager" do
          expect(page).to have_content("User successfully added")
          expect(page).to have_content(organization_manager.email)
          expect(page).to have_content(admin.email)
        end

        describe "When all Users are selected" do
          it "display no more users to add message" do
            expect(page).to have_content("All Users have been added. No Service Managers to add.")
            expect(page).to have_content("All Users have been added. No Submission Viewers to add.")
          end
        end

        describe "limit dropdown to Service Managers from same Organization" do
          let!(:other_org) { FactoryBot.create(:organization, domain: "other.gov") }
          let!(:user_from_other_org) { FactoryBot.create(:user, organization: other_org, email: "user@#{other_org.domain}") }
          let!(:extra_user_from_same_org) { FactoryBot.create(:user, organization: admin.organization, email: "colleague@#{admin.organization.domain}") }

          it "display Users from same Organization" do
            expect(page).to have_content(extra_user_from_same_org.email)
          end

          it "do not display Users from other Organizations" do
            expect(page).to_not have_content(user_from_other_org.email)
          end
        end

      end

      describe "remove Service Manager from Service" do
        before "for a listed User, click Remove" do
          FactoryBot.create(:user_service, user: admin, service: organization_managers_service, role: UserService::Role::ServiceManager)
          visit admin_service_path(organization_managers_service)
          within("table tr[data-user-id='#{organization_manager.id}']") do
            click_link("Remove")
          end
        end

        it "successfully remove User as a Service Manager" do
          expect(page).to have_content("User successfully removed")
          within("table") do
            expect(page).to have_content(admin.email)
            expect(page).to_not have_content(organization_manager.email)
          end
          expect(page).to have_content("Add a User?")
          expect(page).to have_css("#add-user-button[disabled]")
        end
      end
    end
  end

end
