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

RSpec.describe Admin::QuestionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization:) }

  # This should return the minimal set of attributes required to create a valid
  # Question. As you add validations to Question, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # QuestionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Question.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      question = Question.create! valid_attributes
      get :show, params: { id: question.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

    it 'returns a success response' do
      get :new, params: { form_id: form.short_uuid, form_section_id: form.form_sections.first.id }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      question = Question.create! valid_attributes
      get :edit, params: { id: question.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Question' do
        expect do
          post :create, params: { question: valid_attributes }, session: valid_session
        end.to change(Question, :count).by(1)
      end

      it 'redirects to the created question' do
        post :create, params: { question: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Question.last)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { question: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          text: 'Updated question text',
        }
      end

      it 'updates the requested question' do
        question = Question.create! valid_attributes
        put :update, params: { id: question.to_param, question: new_attributes }, session: valid_session
        question.reload
        expect(question.text).eq('Updated question text')
      end

      it 'redirects to the question' do
        question = Question.create! valid_attributes
        put :update, params: { id: question.to_param, question: valid_attributes }, session: valid_session
        expect(response).to redirect_to(question)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        question = Question.create! valid_attributes
        put :update, params: { id: question.to_param, question: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested question' do
      question = Question.create! valid_attributes
      expect do
        delete :destroy, params: { id: question.to_param }, session: valid_session
      end.to change(Question, :count).by(-1)
    end

    it 'redirects to the questions list' do
      question = Question.create! valid_attributes
      delete :destroy, params: { id: question.to_param }, session: valid_session
      expect(response).to redirect_to(questions_url)
    end
  end
end
