# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def login_dot_gov
      @kind = 'Login.gov'
      if auth_hash['info']['all_emails'].present?
        @email = auth_hash['info']['all_emails'].find { |email| email.end_with?('.gov', '.mil') } if auth_hash['info']['email_verified']
      elsif auth_hash['info']['email'].present?
        @email = auth_hash['info']['email'] if auth_hash['info']['email'].end_with?('.gov', '.mil') && auth_hash['info']['email_verified']
      end

      if @email.blank?
        Event.log_event(Event.names[:user_authentication_failure], 'Event::Generic', 1, "Login.gov account with no verified .gov/.mil email attempted to log in on #{Date.today}")
        message = 'This Login.gov account cannot be used to access Touchpoints because it is not associated with a verified .gov or .mil email address. ' \
                  'If you are a government employee, please choose a work-related Login.gov account or follow <a href="https://login.gov/help/manage-your-account/change-your-email-address/">these instructions</a> to add your work email to this Login.gov account.'
        redirect_to index_path, alert: message and return
      end

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

      @user = User.from_omniauth(auth_hash, @email)

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
