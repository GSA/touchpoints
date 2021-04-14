class ProfileController < ApplicationController
  before_action :ensure_user

  def show
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: "User profile updated"
    else
      render :show
    end
  end

  def invite
      invitee = user_params[:refer_user]
      if invitee.present? && invitee =~ URI::MailTo::EMAIL_REGEXP
        if !User.exists?(email: invitee)
          UserMailer.invite(current_user, invitee).deliver_now
          redirect_to profile_path, notice: "Invite sent to #{invitee}"
        else
          redirect_to profile_path, alert: "User with email #{invitee} already exists"
        end
      else
        redirect_to profile_path, alert: "Please enter a valid email address"
      end
  end

private

  def user_params
  	params.require(:user).permit(:time_zone, :api_key, :refer_user)
  end
end
