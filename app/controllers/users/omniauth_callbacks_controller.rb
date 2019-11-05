class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def login_dot_gov
    if (auth_hash && auth_hash["info"]["email_verified"])
      @email = auth_hash["info"]["email"]
    end

    login
  end

  def github
    Rails.logger.debug("** AKT ** login_github")
    Rails.logger.debug("** AKT ** auth_hash: #{auth_hash.to_s}")
    @email = auth_hash["info"]["email"]
    Rails.logger.debug("** AKT ** email: #{@email}")
    login
  end

  def failure
    redirect_to new_user_session_path, alert: "Login.gov error: #{failure_message}"
  end


  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def login
    if @email.present?
      @user = User.from_omniauth(auth_hash)
    end

    Rails.logger.debug("** AKT ** login user #{@user.to_s}")

    # If user exists
    # Else, if valid email and no user, we create an account.
    if !@user.errors.present?
      sign_in_and_redirect(:user, @user)
      set_flash_message(:notice, :success, kind: "Login.gov")
    elsif @user.errors.present?
      redirect_to root_path, alert: @user.errors.full_messages.join(",")
    # else
    #   redirect_to root_path, notice: "Error: During oAuth Login"
    end
  end
end
