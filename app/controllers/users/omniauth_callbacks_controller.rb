class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def login_dot_gov
    @kind = "Login.gov"
    if (auth_hash && auth_hash["info"]["email_verified"])
      @email = auth_hash["info"]["email"]
    end

    login
  end

  def github
    @kind = "GitHub"
    redirect_to index_path, alert: "Invalid request" unless ENV["GITHUB_CLIENT_ID"].present?
    @email = auth_hash["info"]["email"]
    login
  end

  def failure
    redirect_to new_user_session_path, alert: "#{@kind} error: #{failure_message}"
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def login
    Event.log_event(Event.names[:user_authentication_attempt], "Event::Generic", 1, "Email #{@email} attempted to authenticate on #{Date.today}")

    if @email.present?
      @user = User.from_omniauth(auth_hash)
    end

    Event.log_event(Event.names[:user_authentication_successful], "User", @user.id, "User #{@user.email} successfully authenticated on #{Date.today}", @user.id)

    # If user exists
    # Else, if valid email and no user, we create an account.
    if !@user.errors.present?
      sign_in_and_redirect(:user, @user)
    elsif @user.errors.present?
      redirect_to index_path, alert: @user.errors.full_messages.join(",")
    end
  end
end
