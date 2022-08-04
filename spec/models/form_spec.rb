# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :two_question_open_ended_form, organization:, user:) }
  let!(:submission) { FactoryBot.create(:submission, form:) }

  describe 'required attributes' do
    context 'newly created Form' do
      before do
        @form = Form.create({})
      end

      it 'requires name' do
        expect(@form.errors.messages).to have_key(:user)
        expect(@form.errors.messages[:user]).to eq(['must exist'])
      end

      it 'requires organization' do
        expect(@form.errors.messages).to have_key(:organization)
        expect(@form.errors.messages[:organization]).to eq(['must exist'])
      end

      it 'requires user' do
        expect(@form.errors.messages).to have_key(:user)
        expect(@form.errors.messages[:user]).to eq(['must exist'])
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
        second_form_section = form.form_sections.create(title: 'Section 2', position: 2)
        # questions are sorted by Form Section, then Position
        q3 = form.questions.create!(answer_field: 'answer_03', text: '03', form_section_id: form.form_sections.first.id, question_type: 'text_field', position: 4)
        q2 = form.questions.create!(answer_field: 'answer_05', text: '05', form_section_id: form.form_sections.first.id, question_type: 'text_field', position: 3)
        q4 = form.questions.create!(answer_field: 'answer_10', text: '10', form_section_id: second_form_section.id, question_type: 'text_field', position: 5)
        q5 = form.questions.create!(answer_field: 'answer_04', text: '04', form_section_id: second_form_section.id, question_type: 'text_field', position: 6)
      end

      it "returns a hash of questions, location_code, and 'standard' attributes" do
        expect(form.hashed_fields_for_export.class).to eq(Hash)
        expect(form.hashed_fields_for_export.keys).to eq([
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
          :page,
          :referer,
          :created_at,
          :ip_address,
          :tag_list
                                                         ])
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
        expect(csv).to include('Created At')
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
        expect(csv).to include('Created At')
      end
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
    let(:form) { FactoryBot.create(:form, organization:, user: admin) }

    context 'initial state' do
      it 'sets initial state' do
        f = Form.new
        expect(f.in_development?).to eq(true)
      end
    end

    context 'transitionable touchpoint' do
      it 'transitions state' do
        form.develop
        expect(form.in_development?).to eq(true)
        expect(form.live?).to eq(false)
        form.publish
        expect(form.in_development?).to eq(false)
        expect(form.live?).to eq(true)
      end

      it 'transitions from Archived to Live state' do
        form.archive!
        expect(form.archived?).to eq(true)
        form.publish!
        expect(form.live?).to eq(true)
      end
    end

    context 'expired form' do
      before do
        form.update(expiration_date: Date.today - 1)
      end

      it 'archives expired form' do
        expect(form.live?).to eq(true)
        form.check_expired
        expect(form.live?).to eq(false)
        expect(form.archived?).to eq(true)
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
      expect(@duplicate_form.aasm_state).to eq('in_development')
      expect(@duplicate_form.legacy_touchpoint_id).to eq(nil)
      expect(@duplicate_form.legacy_touchpoint_uuid).to eq(nil)
      expect(@duplicate_form.template).to eq(false)
      expect(@duplicate_form.user).to eq(user)
      expect(@duplicate_form.persisted?).to eq(true)
    end
  end

  describe 'dependent data relations' do
    let(:form_without_responses) { FactoryBot.create(:form, :open_ended_form, organization:, user:) }
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
