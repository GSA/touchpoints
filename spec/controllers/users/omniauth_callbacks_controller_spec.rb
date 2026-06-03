# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  let!(:example_organization_gov) { FactoryBot.create(:organization, domain: 'example.gov') }
  let!(:example_organization_mil) { FactoryBot.create(:organization, domain: 'army.mil') }

  describe 'GET #login_dot_gov' do
    context 'with verified .gov email in all_emails array' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12345',
          info: {
            all_emails: ['user@example.gov', 'personal@gmail.com'],
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'successfully authenticates the new user' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_successful], 'User', anything, anything, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to('/admin/forms')
        user = User.find_by(email: 'user@example.gov')
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with verified .mil email in all_emails array' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12346',
          info: {
            all_emails: ['soldier@army.mil', 'personal@gmail.com'],
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'successfully authenticates the new user' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_successful], 'User', anything, anything, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to('/admin/forms')
        user = User.find_by(email: 'soldier@army.mil')
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with verified .gov email in email field' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12347',
          info: {
            email: 'user@example.gov',
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/profile'
      end

      it 'successfully authenticates the new user' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_successful], 'User', anything, anything, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to('/profile')
        user = User.find_by(email: 'user@example.gov')
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with no verified .gov or .mil email' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12348',
          info: {
            all_emails: ['personal@gmail.com'],
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'redirects with error message' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_failure], 'Event::Generic', 1, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to include('This Login.gov account cannot be used')
      end
    end

    context 'with unverified email' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12349',
          info: {
            all_emails: ['user@example.gov'],
            email_verified: false
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'redirects with error message' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_failure], 'Event::Generic', 1, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to include('This Login.gov account cannot be used')
      end
    end

    context 'with no email provided' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12350',
          info: {}
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'redirects with error message' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_failure], 'Event::Generic', 1, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to include('This Login.gov account cannot be used')
      end
    end

    context 'when user creation fails' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12351',
          info: {
            email: 'user@agency.gov',
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/forms'
      end

      it 'redirects with error message' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_failure], 'Event::Generic', 1, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to include("Organization 'agency.gov' has not yet been configured for Touchpoints")
      end
    end

    context 'with existing user migrating from legacy account' do
      let!(:existing_user) { FactoryBot.create(:user, email: 'existing@example.gov', provider: nil, uid: nil) }
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12352',
          info: {
            email: 'existing@example.gov',
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/users'
      end

      it 'updates the existing user with provider and uid' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_successful], 'User', anything, anything, anything)
        
        get :login_dot_gov
        
        expect(response).to redirect_to('/admin/users')
        existing_user.reload
        expect(existing_user.provider).to eq('login_dot_gov')
        expect(existing_user.uid).to eq('12352')
        expect(controller.current_user).to eq(existing_user)
      end
    end

    context 'with existing user already having login.gov credentials' do
      let!(:existing_user) do
        FactoryBot.create(:user, email: 'returning@example.gov', provider: 'login_dot_gov', uid: '12353')
      end
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'login_dot_gov',
          uid: '12353',
          info: {
            email: 'returning@example.gov',
            email_verified: true
          }
        )
      end

      before do
        request.env['omniauth.auth'] = auth_hash
        session['user_return_to'] = '/admin/cx_collections'
      end

      it 'successfully logs in the existing user without creating a new one' do
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_attempt], 'Event::Generic', 1, anything)
        expect(Event).to receive(:log_event).with(Event.names[:user_authentication_successful], 'User', existing_user.id, anything, existing_user.id)
        
        expect do
          get :login_dot_gov
        end.not_to change(User, :count)
        
        expect(response).to redirect_to('/admin/cx_collections')
        expect(controller.current_user).to eq(existing_user)
      end
    end
  end
end
