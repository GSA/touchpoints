require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user] # required for Devise
  end

  describe '#login_dot_gov' do
    let(:auth_hash) do
      {
        'info' => {
          'all_emails' => all_emails,
          'email' => email,
          'email_verified' => email_verified
        }
      }
    end

    before do
      @request.env["omniauth.auth"] = OmniAuth::AuthHash.new(auth_hash)
      allow(Event).to receive(:log_event) # to stub event logging
    end

    context 'when no user is found' do
      let(:all_emails) { nil }
      let(:email) { nil }
      let(:email_verified) { true }

      it 'logs the authentication failure event and redirects to index' do
        expect(User).to receive(:from_omniauth).with(auth_hash, nil).and_return(nil)

        post :login_dot_gov #, params: { provider: 'login_dot_gov' }

        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to match(/Email "" failed to authenticate/)
        expect(Event).to have_received(:log_event).with(anything, 'Event::Generic', 1, /failed to authenticate/)
      end
    end

    context 'when an email is found but user creation fails' do
      let(:all_emails) { ['user@example.gov'] }
      let(:email) { nil }
      let(:email_verified) { true }
      let(:user) { double('User', errors: double(full_messages: ['Error message'])) }

      it 'logs the error and redirects with a message' do
        expect(User).to receive(:from_omniauth).with(auth_hash, 'user@example.gov').and_return(user)
        allow(user).to receive(:blank?).and_return(false)
        allow(user).to receive(:errors).and_return(double(blank?: false, full_messages: ['Error message']))

        get :login_dot_gov, params: { provider: 'login_dot_gov' }

        expect(response).to redirect_to(index_path)
        expect(flash[:alert]).to match(/Error message/)
        expect(Event).to have_received(:log_event).with(anything, 'Event::Generic', 1, /failed to authenticate/)
      end
    end

    # Add more context cases for successful login, email found but no verified email, etc.
  end
end
