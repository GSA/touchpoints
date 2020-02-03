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
    if @email.present?
      @user = User.from_omniauth(auth_hash)
    end

    # If user exists
    # Else, if valid email and no user, we create an account.
    if !@user.errors.present?
      sign_in_and_redirect(:user, @user)
    elsif @user.errors.present?
      redirect_to index_path, alert: @user.errors.full_messages.join(",")
    # else
    #   redirect_to root_path, notice: "Error: During oAuth Login"
    end
  end
end
