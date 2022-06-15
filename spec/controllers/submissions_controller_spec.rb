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

RSpec.describe SubmissionsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Submission. As you add validations to Submission, be sure to
  # adjust the attributes here as well.

  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user: admin) }

  let(:valid_attributes) do
    {
      form_id: form.id,
      answer_01: 'body text',
      answer_02: 'James',
      answer_03: 'Madison',
      answer_04: 'james.madison@lvh.me'
    }
  end

  let(:invalid_attributes) do
    {
      answer_01: nil,
      answer_02: nil,
      answer_03: nil,
      answer_04: nil
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SubmissionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in(admin)
  end

  describe 'GET #new' do
    it 'returns a success response with a Touchpoint ID' do
      get :new, params: { touchpoint_id: form.short_uuid }, session: valid_session
      expect(response).to be_successful
    end

    it 'returns a success response with a Touchpoint UUID' do
      get :new, params: { touchpoint_id: form.short_uuid }, session: valid_session
      expect(response).to be_successful
    end

    it 'returns a fail response with an invalid Touchpoint UUID' do
      expect do
        get :new, params: { touchpoint_id: form.short_uuid.reverse }, session: valid_session
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #create' do
    context 'SPAMBOT' do
      it "won't create a submission if SPAMBOT detected" do
        spam_attributes = {
          form_id: form.id,
          answer_01: 'body text',
          answer_02: 'James',
          answer_03: 'Madison',
          answer_04: 'james.madison@lvh.me',
          fba_directive: 'SPAM text'
        }
        expect do
          post :create, params: { submission: spam_attributes, form_id: form.short_uuid }, session: valid_session
        end.to change(Submission, :count).by(0)
      end
    end

    context 'with valid params and an ID' do
      it 'creates a new Submission' do
        expect do
          post :create, params: { submission: valid_attributes, form_id: form.short_uuid }, session: valid_session
        end.to change(Submission, :count).by(1)
      end

      it 'updates the form response_count and last_response_created_at' do
        post :create, params: { submission: valid_attributes, form_id: form.short_uuid }, session: valid_session
        form.reload
        expect(form.response_count).to be > 0
        expect(form.last_response_created_at).not_to be nil
      end

      it 'redirects to the created submission' do
        post :create, params: { submission: valid_attributes, form_id: form.short_uuid }, session: valid_session
        expect(response).to redirect_to(submit_touchpoint_path(form))
      end
    end

    context 'with valid param and a UUID' do
      it 'creates a new Submission' do
        expect do
          post :create, params: { submission: valid_attributes, form_id: form.short_uuid }, session: valid_session
        end.to change(Submission, :count).by(1)
      end

      it 'redirects to the created submission' do
        post :create, params: { submission: valid_attributes, form_id: form.short_uuid }, session: valid_session
        expect(response).to redirect_to(submit_touchpoint_path(form))
      end
    end

    context 'with invalid params' do
      before do
        form.questions.first.update(is_required: true)
        post :create, params: { submission: invalid_attributes, form_id: form.short_uuid }, session: valid_session,
                      format: :json
      end

      it 'returns an error response indicating the field is required' do
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['messages']).to eq({ 'answer_01' => ['is required'] })
        expect(JSON.parse(response.body)['status']).to eq('unprocessable_entity')
      end
    end

    context 'with excess characters' do
      before do
        form.questions.first.update(character_limit: 5)
        post :create, params: { submission: { answer_01: 'more than 5 characters' }, touchpoint_id: form.short_uuid },
                      session: valid_session, format: :json
      end

      it 'returns an error response indicating character limit has been exceeded' do
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['messages']).to eq({ 'answer_01' => ['exceeds character limit of 5'] })
        expect(JSON.parse(response.body)['status']).to eq('unprocessable_entity')
      end
    end
  end
end
