class ProfileController < ApplicationController
  before_action :ensure_user

  def show
  end

  def update
    current_user.update_attributes(user_params)
    redirect_to profile_path, notice: "User profile updated"
  end

private

  def user_params
  	params.require(:user).permit(:time_zone, :api_key)
  end
end
