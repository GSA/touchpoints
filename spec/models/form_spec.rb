require 'rails_helper'

RSpec.describe Form, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user) }
  let!(:submission) { FactoryBot.create(:submission, form: form) }

  describe "#uuid" do
    context "newly created Form" do
      it "is assigned a 36-char UUID" do
        expect(form.persisted?).to eq(true)
        expect(form.uuid.length).to eq(36)
      end
    end
  end

  describe "#short_uuid" do
    context "newly created Form" do
      it "is assigned an 8-char short_uuid" do
        expect(form.persisted?).to eq(true)
        expect(form.short_uuid.length).to eq(8)
        expect(form.short_uuid).to eq(form.uuid[0..7])
      end
    end
  end

  describe "#user_role?" do
    context "without user_role" do
      it "returns nil" do
        expect(form.user_role?(user: user)).to be_nil
      end
    end

    context "with user_role" do
      let!(:user_role) { FactoryBot.create(:user_role, user: user, form: form, role: UserRole::Role::FormManager)}

      it "returns the role as a string" do
        expect(form.user_role?(user: user)).to eq("form_manager")
      end
    end

    context "with user_role" do
      let!(:user_role) { FactoryBot.create(:user_role, user: user, form: form, role: UserRole::Role::ResponseViewer)}

      it "returns the role as a string" do
        expect(form.user_role?(user: user)).to eq("response_viewer")
      end
    end
  end

  describe "#to_csv" do
    it "returns Submission fields" do
      csv = form.to_csv.to_s

      expect(csv).to include("IP Address")
      expect(csv).to include("User Agent")
      expect(csv).to include("Page")
      expect(csv).to include("Referrer")
      expect(csv).to include("Created At")
    end
  end

  describe "#to_a11_header_csv" do
    it "returns Submission fields" do
      csv = form.to_a11_header_csv(start_date: Time.now.to_date, end_date: (Time.now + 3.months).to_date)

      expect(csv).to include("submission comment")
      expect(csv).to include("survey_instrument_reference")
      expect(csv).to include("agency_poc_name")
      expect(csv).to include("agency_poc_email")
      expect(csv).to include("department")
      expect(csv).to include("bureau")
      expect(csv).to include("service")
      expect(csv).to include("transaction_point")
      expect(csv).to include("mode")
      expect(csv).to include("start_date")
      expect(csv).to include("end_date")
      expect(csv).to include("total_volume")
      expect(csv).to include("survey_opp_volume")
      expect(csv).to include("response_count")
      expect(csv).to include("OMB_control_number")
      expect(csv).to include("federal_register_url")
    end
  end

  describe "#user_roles" do
    let!(:user_role) { FactoryBot.create(:user_role, user: user, form: form, role: UserRole::Role::FormManager)}

    before do
      form.submissions.destroy_all # manually remove the Form's seeded submission

      expect(UserRole.count).to eq(1)
      form.destroy
    end

    it "delete User Roles when Form is deleted" do
      expect(UserRole.count).to eq(0)
    end
  end
end
