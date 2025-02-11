# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe Admin::FormsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Form. As you add validations to Form, be sure to
  # adjust the attributes here as well.
  let(:organization) { FactoryBot.create(:organization) }
  let!(:form) { FactoryBot.create(:form, :two_question_open_ended_form, organization:) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:user_role) { FactoryBot.create(:user_role, user: admin, form: form, role: UserRole::Role::FormManager) }

  let(:valid_attributes) do
    FactoryBot.build(:form, organization: organization).attributes
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FormsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in(admin)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Form.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      form = Form.create! valid_attributes
      get :show, params: { id: form.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #notifications' do
    it 'returns a success response' do
      form = Form.create! valid_attributes
      get :show, params: { id: form.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    before do
      sign_in(admin)
    end

    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    before do
      sign_in(admin)
    end

    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      form = Form.create! valid_attributes
      get :edit, params: { id: form.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Form' do
        expect do
          post :create, params: { form: valid_attributes }, session: valid_session
        end.to change(Form, :count).by(1)
      end

      it 'redirects to the created form' do
        post :create, params: { form: valid_attributes }, session: valid_session
        expect(response).to redirect_to questions_admin_form_path(Form.last)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { form: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #archive' do
    before do
      sign_in(admin)
    end

    context 'with valid params' do
      before do
        form.created_at = Time.now - 2.weeks
        20.times { FactoryBot.create(:submission, form: form) }
        form.save!
      end

      it "queues 2 emails, rather than 1, because form is more than 1 week old" do
        expect(UserMailer).to receive_message_chain(:form_feedback, :deliver_later)
        expect(UserMailer).to receive_message_chain(:form_status_changed, :deliver_later)

        post :archive, params: { id: form.to_param }
        expect(response).to redirect_to admin_form_path(form)
      end
    end

    context 'with invalid params' do
      before do
        form.created_at = Time.now - 1.day
        form.save
      end

      it "queues 1 emails because form is not 7 days old" do
        expect(UserMailer).not_to receive(:form_feedback)
        expect(UserMailer).to receive_message_chain(:form_status_changed, :deliver_later)

        post :archive, params: { id: form.short_uuid }, session: valid_session
        expect(response).to redirect_to admin_form_path(form)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested form' do
        form = Form.create! valid_attributes
        put :update, params: { id: form.to_param, form: new_attributes }, session: valid_session
        form.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the form' do
        form = Form.create! valid_attributes
        put :update, params: { id: form.to_param, form: valid_attributes }, session: valid_session
        expect(response).to redirect_to delivery_admin_form_path(form)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        form = Form.create! valid_attributes
        put :update, params: { id: form.to_param, form: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested form' do
      form = Form.create! valid_attributes
      expect do
        delete :destroy, params: { id: form.to_param }, session: valid_session
      end.to change(Form, :count).by(-1)
    end

    it 'redirects to the forms list' do
      form = Form.create! valid_attributes
      delete :destroy, params: { id: form.to_param }, session: valid_session
      expect(response).to redirect_to(admin_forms_url)
    end
  end

  describe 'GET #export' do
    let(:start_date) { '2024-01-01' }
    let(:end_date) { '2024-01-28' }
    let!(:submission1) { FactoryBot.create(:submission, form:, created_at: '2024-01-01 08:00:00') }
    let!(:submission2) { FactoryBot.create(:submission, form:, created_at: '2024-01-15 12:00:00') }
    let!(:submission3) { FactoryBot.create(:submission, form:, created_at: '2024-01-28 23:59:59') }
    let!(:out_of_range) { FactoryBot.create(:submission, form:, created_at: '2024-01-29 00:00:01') }

    context 'when response count is within the small download limit' do
      it 'sends a CSV file' do
        get :export, params: { id: form.short_uuid, start_date: start_date, end_date: end_date }
        expect(response.content_type).to include('text/csv')
        expect(response.status).to eq(200)
        expect(response.body).to include("ID,UUID,Test Text Field,Test Open Area,Location Code,User Agent,Status,Archived,Flagged,Deleted,Deleted at,Page,Query string,Hostname,Referrer,Created at,IP Address,Tags")
        expect(response.body).to include(submission1.created_at.to_s)
        expect(response.body).to include(submission2.created_at.to_s)
        expect(response.body).to include(submission3.created_at.to_s)
        expect(response.body).to_not include(out_of_range.created_at.to_s)
      end
    end

    context 'when response count exceeds small download limit but is within async job range' do
      before do
        allow(Form).to receive(:find_by_short_uuid).with(form.short_uuid).and_return(form)
        allow(form).to receive(:non_flagged_submissions).and_return(double(count: 1_500))
        allow(ExportJob).to receive(:perform_later)
      end

      it 'queues an async export job and redirects' do
        get :export, params: { id: form.short_uuid, start_date: start_date, end_date: end_date }

        expect(ExportJob).to have_received(:perform_later).with(admin.email, form.short_uuid, "2024-01-01 00:00:00 UTC", "2024-01-28 23:59:59 UTC")
        expect(response).to redirect_to(responses_admin_form_path(form))
        expect(flash[:success]).to eq(UserMailer::ASYNC_JOB_MESSAGE)
      end
    end

    context 'when response count exceeds the maximum allowed export' do
      before do
        allow(Form).to receive(:find_by_short_uuid).with(form.short_uuid).and_return(form)
        allow(form).to receive(:non_flagged_submissions).and_return(double(count: described_class::MAX_ROWS_TO_EXPORT + 1))
      end

      it 'returns a bad request error' do
        get :export, params: { id: form.short_uuid, start_date: start_date, end_date: end_date }

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include("Your response set contains")
      end
    end

    context 'when no date parameters are provided' do
      let(:default_start) { Time.zone.now.beginning_of_quarter }
      let(:default_end) { Time.zone.now.end_of_quarter }
      let!(:submission1) { FactoryBot.create(:submission, form:, created_at: default_start + 1.day) }
      let!(:submission2) { FactoryBot.create(:submission, form:, created_at: default_start + 2.days) }
      let!(:submission3) { FactoryBot.create(:submission, form:, created_at: default_start + 3.days) }
      let!(:out_of_range1) { FactoryBot.create(:submission, form:, created_at: default_start - 1.day) }
      let!(:out_of_range2) { FactoryBot.create(:submission, form:, created_at: default_end + 1.day) }

      it 'uses the default quarter range' do
        get :export, params: { id: form.short_uuid }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(submission1.created_at.to_s)
        expect(response.body).to include(submission2.created_at.to_s)
        expect(response.body).to include(submission3.created_at.to_s)
        expect(response.body).to_not include(out_of_range1.created_at.to_s)
        expect(response.body).to_not include(out_of_range2.created_at.to_s)
      end
    end
  end

end
