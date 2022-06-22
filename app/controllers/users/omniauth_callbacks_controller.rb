# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def login_dot_gov
      @kind = 'Login.gov'
      @email = auth_hash['info']['email'] if auth_hash && auth_hash['info']['email_verified']

      login
    end

    def github
      @kind = 'GitHub'
      redirect_to index_path, alert: 'Invalid request' if ENV['GITHUB_CLIENT_ID'].blank?
      @email = auth_hash['info']['email']
      login
    end

    def failure
      Event.log_event(Event.names[:user_authentication_failure], 'Event::Generic', 1, "Email #{@email} failed to authenticate on #{Date.today}. #{failure_message}")
      redirect_to new_user_session_path, alert: "#{@kind} error: #{failure_message}"
    end

    private

    def auth_hash
      request.env['omniauth.auth']
    end

    def login
      Event.log_event(Event.names[:user_authentication_attempt], 'Event::Generic', 1, "Email #{@email} attempted to authenticate on #{Date.today}")

      @user = User.from_omniauth(auth_hash) if @email.present?

      # If user exists
      # Else, if valid email and no user, we create an account.
      if @user.errors.blank?
        Event.log_event(Event.names[:user_authentication_successful], 'User', @user.id, "User #{@user.email} successfully authenticated on #{Date.today}", @user.id)
        sign_in_and_redirect(:user, @user)
      elsif @user.errors.present?
        Event.log_event(Event.names[:user_authentication_failure], 'Event::Generic', 1, "Email #{@email} failed to authenticate on #{Date.today}. #{@user.errors.full_messages}")
        redirect_to index_path, alert: @user.errors.full_messages.join(',')
      end
    end
  end
end
