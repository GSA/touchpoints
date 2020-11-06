require 'rails_helper'

feature "Admin Dashboard", js: true do

  describe "Admin" do
    let(:organization) { FactoryBot.create(:organization)}
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    before do
      login_as admin
      visit admin_dashboard_path
    end

    it "display admin links" do
      expect(page).to have_link("Organizations")
      expect(page).to have_link("Users")
      expect(page).to have_link("Manage Sidekiq")
    end

    describe "weekly metrics" do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, hisp: true) }
      let!(:form_template) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, template: true) }

      before do
        visit admin_dashboard_path
      end

      it "display weekly metrics" do
        expect(page).to have_content("Weekly Product & Program Use Metrics")
        expect(page).to have_content("Agencies with Forms")
        expect(find(".reportable-organizations")).to have_content("1")
        expect(find(".reportable-forms")).to have_content("1")
        expect(find(".reportable-submissions")).to have_content("0")
      end
    end

    describe "daily totals" do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, hisp: true) }
      let!(:form_template) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, template: true) }

      before do
        Submission.create({
          form_id: form.id,
          answer_01: "yes",
          created_at: Time.now - 10.days
        })
        Submission.create({
          form_id: form.id,
          answer_01: "yes",
          created_at: Time.now - 5.days
        })
        Submission.create({
          form_id: form.id,
          answer_01: "yes",
          created_at: Time.now - 5.days
        })
        visit admin_dashboard_path
      end

      it "display weekly metrics" do
        expect(page).to have_css("#daily-responses")
        expect(page).to have_css("canvas")
      end
    end

    describe "with HISP forms" do
      let!(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: admin, hisp: true) }

      before do
        visit admin_dashboard_path
      end

      it "display HISP forms" do
        expect(page).to have_content("Weekly Product & Program Use Metrics")
        expect(page).to have_content("Agencies with Forms")
        expect(page).to have_content(form.organization.name)
        expect(page).to have_link(form.name)
        expect(page).to have_content("0 responses")
      end
    end
  end

  # Note:
  # Public users do not log in.
  # Logged in users are .gov users, but may not have permissions
  #  to edit any Services or other resources
  describe "non-privileged User" do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as user
      visit admin_dashboard_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Create a Form")
      expect(page).to have_content("Customize the Form with Questions and Question Options")
      expect(page).to have_content("Test the Form by creating a Response")
      expect(page).to have_content("Deploy the Form to Users on your website or via your email system")
      expect(page).to have_content("Receive feedback from Users")
      expect(page).to have_content("Use the feedback to improve service delivery")
    end
  end

  describe "non logged-in User" do
    before do
      visit admin_root_path
    end

    it "redirected to home page and sees flash message" do
      expect(page.current_path).to eq(index_path)
      expect(page).to have_content("Authorization is Required")
    end
  end
end
