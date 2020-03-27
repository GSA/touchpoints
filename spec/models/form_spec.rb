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

  describe "validate state transitions" do
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
    let(:form) { FactoryBot.create(:form, organization: organization, user: admin)}

    context "initial state" do
      it "sets initial state" do
        f = Form.new
        expect(f.in_development?).to eq(true)
      end
    end

    context "transitionable touchpoint" do
      it "transitions state" do
        form.develop
        expect(form.in_development?).to eq(true)
        expect(form.live?).to eq(false)
        form.publish
        expect(form.in_development?).to eq(false)
        expect(form.live?).to eq(true)
      end
    end

    context "expired form" do
      it "archives expired form" do
        form.publish
        expect(form.live?).to eq(true)
        form.expiration_date = Date.today - 1
        form.check_expired
        expect(form.live?).to eq(false)
        expect(form.archived?).to eq(true)
      end
    end
  end

  describe "dependent data relations" do
    let(:form_without_responses) { FactoryBot.create(:form, :open_ended_form, organization: organization, user: user) }
    let!(:user_role) { FactoryBot.create(:user_role, user: user, form: form_without_responses, role: UserRole::Role::FormManager)}

    describe "delete the Form's Form Sections" do
      before do
        expect(form_without_responses.form_sections.count).to eq 1
      end

      it "destroys dependent Form Section" do
        expect { form_without_responses.destroy }.to change { FormSection.count }.by(-1)
      end
    end

    describe "delete the Form's Questions" do
      before do
        expect(form_without_responses.questions.count).to eq 1
      end

      it "destroys dependent Questions" do
        expect { form_without_responses.destroy }.to change { Question.count }.by(-1)
      end
    end

    describe "delete the Form's UserRoles" do
      before do
        expect(form_without_responses.user_roles.count).to eq 1
      end

      it "destroys dependent UserRole" do
        expect { form_without_responses.destroy }.to change { UserRole.count }.by(-1)
      end
    end
  end
end
