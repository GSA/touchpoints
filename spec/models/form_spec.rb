# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let!(:form) { FactoryBot.create(:form, :two_question_open_ended_form, organization:) }
  let!(:submission) { FactoryBot.create(:submission, form:) }

  describe 'required attributes' do
    context 'newly created Form' do
      before do
        @form = Form.create({})
      end

      it 'requires organization' do
        expect(@form.errors.messages).to have_key(:organization)
        expect(@form.errors.messages[:organization]).to eq(['must exist'])
      end

      it 'requires delivery_method' do
        expect(@form.errors.messages).to have_key(:delivery_method)
        expect(@form.errors.messages[:delivery_method]).to eq(["can't be blank"])
      end
    end
  end

  context 'newly created Form' do
    describe '#uuid' do
      it 'is assigned a 36-char UUID' do
        expect(form.persisted?).to eq(true)
        expect(form.uuid.length).to eq(36)
      end
    end

    describe '#hashed_fields_for_export' do
      before do
        # questions are sorted by Form Section, then Position
        q4 = form.form_sections.first.questions.create!(form: form, answer_field: 'answer_03', text: '03', question_type: 'text_field', position: 4)
        q3 = form.form_sections.first.questions.create!(form: form, answer_field: 'answer_05', text: '05', question_type: 'text_field', position: 3)

        second_form_section = form.form_sections.create(title: 'Section 2', position: 2)
        q5 = second_form_section.questions.create!(form: form, answer_field: 'answer_10', text: '10', question_type: 'text_field', position: 5)
        q6 = second_form_section.questions.create!(form: form, answer_field: 'answer_04', text: '04', question_type: 'text_field', position: 6)
      end

      it "returns a hash of questions, location_code, and 'standard' attributes" do
        expect(form.hashed_fields_for_export.class).to eq(ActiveSupport::OrderedHash)
        expect(form.hashed_fields_for_export.keys).to eq([
          :id,
          :uuid,
          # question fields
          'answer_01',
          'answer_02',
          'answer_05',
          'answer_03',
          'answer_10',
          'answer_04',
          # custom location code
          :location_code,
          # standard fields
          :user_agent,
          :aasm_state,
          :archived,
          :flagged,
          :deleted,
          :deleted_at,
          :page,
          :query_string,
          :hostname,
          :referer,
          :created_at,
          :ip_address,
          :tags
        ])
      end
    end
  end

  describe '#kinds' do
    context 'invalid form kind' do
      let!(:form_with_invalid_kind) { FactoryBot.build(:form, organization:, kind: "some_non_valid_kind") }

      before do
        form_with_invalid_kind.save
      end

      it 'adds an error for kind' do
        expect(form_with_invalid_kind.errors.messages[:kind]).to eq(['kind must be one of the following: a11, a11_v2, a11_yes_no, custom, open_ended, other, recruiter, yes_no'])
      end
    end

    context 'valid form kind' do
      let!(:form_with_valid_kind) { FactoryBot.build(:form, organization:, kind: "open_ended") }

      before do
        form_with_valid_kind.save
      end

      it 'ensure valid form kind' do
        expect(form_with_valid_kind.errors).to be_empty
      end
    end
  end

  describe '#short_uuid' do
    context 'newly created Form' do
      it 'is assigned an 8-char short_uuid' do
        expect(form.persisted?).to eq(true)
        expect(form.short_uuid.length).to eq(8)
        expect(form.short_uuid).to eq(form.uuid[0..7])
      end
    end
  end

  describe '#user_role?' do
    context 'without user_role' do
      it 'returns nil' do
        expect(form.user_role?(user:)).to be_nil
      end
    end

    context 'with user_role' do
      let!(:user_role) { FactoryBot.create(:user_role, user:, form:, role: UserRole::Role::FormManager) }

      it 'returns the role as a string' do
        expect(form.user_role?(user:)).to eq('form_manager')
      end
    end

    context 'with user_role' do
      let!(:user_role) { FactoryBot.create(:user_role, user:, form:, role: UserRole::Role::ResponseViewer) }

      it 'returns the role as a string' do
        expect(form.user_role?(user:)).to eq('response_viewer')
      end
    end
  end

  describe '#to_csv' do
    context 'an Organization with enabled IP address' do
      before do
        organization.update(enable_ip_address: true)
        form.reload
      end

      it 'returns Submission fields' do
        csv = form.to_csv(start_date: Time.zone.now.beginning_of_quarter, end_date: Time.zone.now.end_of_quarter).to_s

        expect(csv).to include('IP Address')
        expect(csv).to include('User Agent')
        expect(csv).to include('Page')
        expect(csv).to include('Referrer')
        expect(csv).to include('Created at')
        expect(csv).to include('Deleted at')
      end
    end

    context 'an Organization without enabled IP address' do
      before do
        organization.update(enable_ip_address: false)
        form.reload
      end

      it 'returns Submission fields' do
        csv = form.to_csv(start_date: Time.zone.now.beginning_of_quarter, end_date: Time.zone.now.end_of_quarter).to_s

        expect(csv).to_not include('IP Address')
        expect(csv).to include('User Agent')
        expect(csv).to include('Page')
        expect(csv).to include('Referrer')
        expect(csv).to include('Created at')
        expect(csv).to include('Deleted at')
      end
    end
  end

  describe '#reportable_submissions' do
    let!(:submission1) { FactoryBot.create(:submission, form:, created_at: '2024-01-01 08:00:00') }
    let!(:submission2) { FactoryBot.create(:submission, form:, created_at: '2024-01-15 12:00:00') }
    let!(:submission3) { FactoryBot.create(:submission, form:, created_at: '2024-01-28 23:59:59') }
    let!(:flagged_submission) { FactoryBot.create(:submission, form:, created_at: '2024-01-18 23:59:59', flagged: true) }
    let!(:spam_submission) { FactoryBot.create(:submission, form:, created_at: '2024-01-22 23:59:59', spam: true) }
    let!(:deleted_submission) { FactoryBot.create(:submission, form:, created_at: '2024-01-27 23:59:59', deleted: true) }
    let!(:out_of_range) { FactoryBot.create(:submission, form:, created_at: '2024-01-29 00:00:01') }

    before do
      start_date = Date.parse('2024-01-01').beginning_of_day
      end_date = Date.parse('2024-01-28').end_of_day
      @results = form.reportable_submissions(start_date:, end_date:)
    end

    it 'includes submissions up to and including the end_date' do
      expect(@results).to include(submission1, submission2, submission3)
      expect(@results).not_to include(out_of_range)
    end
  end

  describe '#to_a11_header_csv' do
    it 'returns Submission fields' do
      csv = form.to_a11_header_csv(start_date: Time.zone.now.to_date, end_date: 3.months.from_now.to_date)

      expect(csv).to include('submission comment')
      expect(csv).to include('survey_instrument_reference')
      expect(csv).to include('agency_poc_name')
      expect(csv).to include('agency_poc_email')
      expect(csv).to include('department')
      expect(csv).to include('bureau')
      expect(csv).to include('service')
      expect(csv).to include('transaction_point')
      expect(csv).to include('mode')
      expect(csv).to include('start_date')
      expect(csv).to include('end_date')
      expect(csv).to include('total_volume')
      expect(csv).to include('survey_opp_volume')
      expect(csv).to include('response_count')
      expect(csv).to include('OMB_control_number')
      expect(csv).to include('federal_register_url')
    end
  end

  describe '#user_roles' do
    let!(:user_role) { FactoryBot.create(:user_role, user:, form:, role: UserRole::Role::FormManager) }

    before do
      form.submissions.destroy_all # manually remove the Form's seeded submission
      form.form_sections.first.questions.delete_all

      expect(UserRole.count).to eq(1)
      form.destroy
    end

    it 'delete User Roles when Form is deleted' do
      expect(UserRole.count).to eq(0)
    end
  end

  describe 'validate state transitions' do
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }
    let(:form_2) { FactoryBot.create(:form, organization:) }

    context 'initial state' do
      it 'sets initial state' do
        f = Form.new
        expect(f.created?).to eq(true)
      end
    end

    context 'transitionable touchpoint' do
      it 'transitions state' do
        form_2.reset!
        expect(form_2.created?).to eq(true)
        expect(form_2.published?).to eq(false)
        form_2.publish!
        expect(form_2.created?).to eq(false)
        expect(form_2.published?).to eq(true)
      end
    end

    context 'expired form' do
      before do
        form_2.update(expiration_date: Date.today - 1)
      end

      it 'archives expired form' do
        expect(form_2.published?).to eq(true)
        form_2.check_expired
        expect(form_2.published?).to eq(false)
        expect(form_2.archived?).to eq(true)
      end
    end

    context 'archive form' do
      it "records 'archived_at' timestamp" do
        expect(form_2.archived_at).to be_nil
        form_2.archive
        expect(form_2.archived_at).to_not be_nil
      end
    end
  end

  describe '#duplicate!' do
    before do
      @duplicate_form = form.duplicate!(new_user: user)
    end

    it "adds 'Copy' to name" do
      expect(@duplicate_form.name).to eq("Copy of #{form.name}")
    end

    it 'resets survey_form_activations to 0' do
      expect(@duplicate_form.survey_form_activations).to eq(0)
    end

    it 'resets many other attributes' do
      expect(@duplicate_form.aasm_state).to eq('created')
      expect(@duplicate_form.legacy_touchpoint_id).to eq(nil)
      expect(@duplicate_form.legacy_touchpoint_uuid).to eq(nil)
      expect(@duplicate_form.template).to eq(false)
      expect(@duplicate_form.organization).to eq(organization)
      expect(@duplicate_form.persisted?).to eq(true)
    end
  end

  describe 'dependent data relations' do
    let(:form_without_responses) { FactoryBot.create(:form, :open_ended_form, organization:) }
    let!(:user_role) { FactoryBot.create(:user_role, user:, form: form_without_responses, role: UserRole::Role::FormManager) }

    before do
      expect(form_without_responses.form_sections.count).to eq 1
      expect(form_without_responses.user_roles.count).to eq 1
      form_without_responses.form_sections.first.questions.delete_all
    end

    describe "delete the Form's Form Sections" do
      it 'destroys dependent Form Section' do
        expect { form_without_responses.destroy }.to change { FormSection.count }.by(-1)
      end
    end

    describe "delete the Form's Questions" do
      it 'destroys dependent Questions' do
        expect { form_without_responses.destroy }.to change { Question.count }.by(-1)
      end
    end

    describe "delete the Form's UserRoles" do
      it 'destroys dependent UserRole' do
        expect { form_without_responses.destroy }.to change { UserRole.count }.by(-1)
      end
    end
  end
end
